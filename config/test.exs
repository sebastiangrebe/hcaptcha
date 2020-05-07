use Mix.Config

config :hcaptcha,
  http_client: Hcaptcha.Http.MockClient,
  secret: "test_secret",
  public_key: "test_public_key"
