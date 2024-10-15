defmodule Hcaptcha.Http do
  @moduledoc """
   Responsible for managing HTTP requests to the hCAPTCHA API
  """

  alias Hcaptcha.Config

  @headers [
    {"Content-type", "application/x-www-form-urlencoded"},
    {"Accept", "application/json"}
  ]

  @default_verify_url "https://hcaptcha.com/siteverify"

  @json_library Application.compile_env(:hcaptcha, :json_library, Jason)

  @doc """
  Sends an HTTP request to the hCAPTCHA version 2.0 API.

  See the [docs](https://developers.google.com/hcaptcha/docs/verify#api-response)
  for more details on the API response.

  ## Options

    * `:timeout` - the timeout for the request (defaults to 5000ms)

  ## Example

    {:ok, %{
      "success" => success,
      "challenge_ts" => ts,
      "hostname" => host,
      "error-codes" => errors
    }} = Hcaptcha.Http.request_verification(%{
      secret: "secret",
      response: "response",
      remote_ip: "remote_ip"
    })
  """
  @spec request_verification(binary, timeout: integer) ::
          {:ok, map} | {:error, [atom]}
  def request_verification(body, options \\ []) do
    timeout = options[:timeout] || Config.get_env(:hcaptcha, :timeout, 5000)
    url = Config.get_env(:hcaptcha, :verify_url, @default_verify_url)

    result =
      with {:ok, response} <-
             HTTPoison.post(url, body, @headers, timeout: timeout),
           {:ok, data} <- @json_library.decode(response.body) do
        {:ok, data}
      end

    case result do
      {:ok, data} -> {:ok, data}
      {:error, :invalid} -> {:error, [:invalid_api_response]}
      {:error, {:invalid, _reason}} -> {:error, [:invalid_api_response]}
      {:error, %{reason: reason}} -> {:error, [reason]}
    end
  end
end
