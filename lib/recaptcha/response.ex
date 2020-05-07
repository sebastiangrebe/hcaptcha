defmodule Hcaptcha.Response do
  @moduledoc """
    A struct representing the successful hcaptcha response from the reCAPTCHA API.
  """
  defstruct challenge_ts: "", hostname: ""

  @type t :: %__MODULE__{challenge_ts: String.t(), hostname: String.t()}
end
