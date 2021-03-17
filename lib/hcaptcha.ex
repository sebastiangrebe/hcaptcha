defmodule Hcaptcha do
  @moduledoc """
    A module for verifying hCAPTCHA version 2.0 response strings.

    See the [documentation](https://developers.google.com/hcaptcha/docs/verify)
    for more details.
  """

  alias Hcaptcha.{Config, Http, Response}

  @http_client Application.get_env(:hcaptcha, :http_client, Http)

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
    # See why we are using `to_atom` here:
    # https://github.com/samueljseay/recaptcha/pull/28#issuecomment-313604733
    error
    |> String.replace("-", "_")
    |> String.to_atom()
  end
end
