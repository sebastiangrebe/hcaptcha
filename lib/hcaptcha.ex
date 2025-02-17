defmodule Hcaptcha do
  @moduledoc """
    A module for verifying hCAPTCHA version 1 response strings.

    See the [documentation](https://docs.hcaptcha.com/) for more details.
  """

  alias Hcaptcha.{Config, Http, Response}

  @http_client Application.compile_env(:hcaptcha, :http_client, Http)

  # https://docs.hcaptcha.com/#siteverify-error-codes-table
  @error_codes_map %{
    # Your secret key is missing.
    "missing-input-secret" => :missing_input_secret,
    # Your secret key is invalid or malformed.
    "invalid-input-secret" => :invalid_input_secret,
    # The response parameter (verification token) is missing.
    "missing-input-response" => :missing_input_response,
    # The response parameter (verification token) is invalid or malformed.
    "invalid-input-response" => :invalid_input_response,
    # The request is invalid or malformed.
    "bad-request" => :bad_request,
    # The response parameter has already been checked, or has another issue.
    "invalid-or-already-seen-response" => :invalid_or_already_seen_response,
    # You have used a testing sitekey but have not used its matching secret.
    "not-using-dummy-passcode" => :not_using_dummy_passcode,
    # The sitekey is not registered with the provided secret.
    "sitekey-secret-mismatch" => :sitekey_secret_mismatch
  }

  @doc """
  Verifies a hCAPTCHA response string.

  ## Options

    * `:timeout` - the timeout for the request (defaults to 5000ms)
    * `:secret`  - the secret key used by hcaptcha (defaults to the secret
      provided in application config)
    * `:remote_ip` - the IP address of the user (optional and not set by default)

  ## Example

    {:ok, api_response} = Hcaptcha.verify("response_string")
  """
  @spec verify(String.t(), Keyword.t()) ::
          {:ok, Response.t()} | {:error, [atom]}
  def verify(response, options \\ []) do
    verification =
      @http_client.request_verification(
        request_body(response, options),
        Keyword.take(options, [:timeout])
      )

    case verification do
      {:error, errors} ->
        {:error, errors}

      {:ok, %{"success" => false, "error-codes" => errors}} ->
        {:error, Enum.map(errors, &atomise_api_error/1)}

      {:ok,
       %{"success" => true, "challenge_ts" => timestamp, "hostname" => host}} ->
        {:ok, %Response{challenge_ts: timestamp, hostname: host}}

      {:ok,
       %{"success" => false, "challenge_ts" => _timestamp, "hostname" => _host}} ->
        {:error, [:challenge_failed]}
    end
  end

  defp request_body(response, options) do
    body_options = Keyword.take(options, [:remote_ip, :secret])
    application_options = [secret: Config.get_env(:hcaptcha, :secret)]

    # override application secret with options secret if it exists
    application_options
    |> Keyword.merge(body_options)
    |> Keyword.put(:response, response)
    |> URI.encode_query()
  end

  defp atomise_api_error(error) do
    Map.get(@error_codes_map, error, :unknown_error)
  end
end
