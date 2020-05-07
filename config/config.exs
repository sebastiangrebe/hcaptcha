use Mix.Config

config :hcaptcha,
  verify_url: "https://hcaptcha.com/siteverify",
  timeout: 5000,
  public_key: {:system, "HCAPTCHA_PUBLIC_KEY"},
  secret: {:system, "HCAPTCHA_PRIVATE_KEY"}

config :hcaptcha, :json_library, Jason

import_config "#{Mix.env()}.exs"
