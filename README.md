# Hcaptcha

[![Hex.pm](https://img.shields.io/badge/Hex-v2.1.1-green.svg)](https://hexdocs.pm/hcaptcha)

A simple Elixir package for implementing [hCAPTCHA] in Elixir applications.

[hCAPTCHA]: https://www.hcaptcha.com/

The package is fork of the [recaptcha] package which uses the same flow as needed for hCaptcha. It would also be possible to integrate hCaptcha in this package but I was not able to wait for PRs to be merged so I just forked the repo.

[recaptcha]: https://github.com/samueljseay/recaptcha

### Important Notice
The repo works for me but is not tested that all configuration options or callbacks given by hCaptcha are processed correctly. Feel free to open PRs to resolve dependencies on the recaptcha API.

## Installation

1. Add hcaptcha to your `mix.exs` dependencies

```elixir
  defp deps do
    [
      {:hcaptcha, "~> 0.0.2"},
    ]
  end
```

2. List `:hcaptcha` as an application dependency

```elixir
  def application do
    [ extra_applications: [:hcaptcha] ]
  end
```

3. Run `mix do deps.get, compile`

## Config

By default the public and private keys are loaded via the `HCAPTCHA_PUBLIC_KEY` and `HCAPTCHA_PRIVATE_KEY` environment variables.

```elixir
  config :hcaptcha,
    public_key: {:system, "HCAPTCHA_PUBLIC_KEY"},
    secret: {:system, "HCAPTCHA_PRIVATE_KEY"}
```

### JSON Decoding

By default `hCaptcha` will use `Jason` to decode JSON responses, this can be changed as such:

```elixir
  config :hcaptcha, :json_library, Poison
```

## Usage

### Render the Widget

Use `raw` (if you're using Phoenix.HTML) and `Hcaptcha.Template.display/1` methods to render the captcha widget.

For hcaptcha with checkbox
```html
<form name="someform" method="post" action="/somewhere">
  ...
  <%= raw Hcaptcha.Template.display %>
  ...
</form>
```

For invisible hcaptcha
```html
<form name="someform" method="post" action="/somewhere">
  ...
  <%= raw Hcaptcha.Template.display(size: "invisible") %>
</form>
  ...
```

Since hcaptcha loads Javascript code asynchronously, you cannot immediately submit the captcha form.
If you have logic that needs to know if the captcha code has already been loaded (for example disabling submit button until fully loaded), it is possible to pass in a JS-callback that will be called once the captcha has finished loading.
This can be done as follows:

```html
<form name="someform" method="post" action="/somewhere">
  ...
  <%= raw Hcaptcha.Template.display(onload: "myOnLoadCallback") %>
</form>
  ...
```

And then in your JS code:

```javascript
function myOnLoadCallback() {
  // perform extra actions here
}
```

`display` method accepts additional options as a keyword list, the options are:

Option                  | Action                                                 | Default
:---------------------- | :----------------------------------------------------- | :------------------------
`noscript`              | Renders default noscript code provided by google       | `false`
`public_key`            | Sets key to the `data-sitekey` hCaptcha div attribute | Public key from the config file
`hl`                    | Sets the language of the hCaptcha                     | en

### Verify API

Hcaptcha provides the `verify/2` method. Below is an example using a Phoenix controller action:

```elixir
  def create(conn, params) do
    case Hcaptcha.verify(params["h-captcha-response"]) do
      {:ok, response} -> do_something
      {:error, errors} -> handle_error
    end
  end
```

`verify` method sends a `POST` request to the hCAPTCHA API and returns 2 possible values:

`{:ok, %Hcaptcha.Response{challenge_ts: timestamp, hostname: host}}` -> The captcha is valid, see the [documentation](https://developers.google.com/hcaptcha/docs/verify#api-response) for more details.

`{:error, errors}` -> `errors` contains atomised versions of the errors returned by the API, See the [error documentation](https://developers.google.com/hcaptcha/docs/verify#error-code-reference) for more details. Errors caused by timeouts in HTTPoison or Jason encoding are also returned as atoms. If the hcaptcha request succeeds but the challenge is failed, a `:challenge_failed` error is returned.

`verify` method also accepts a keyword list as the third parameter with the following options:

Option                  | Action                                                 | Default
:---------------------- | :----------------------------------------------------- | :------------------------
`timeout`               | Time to wait before timeout                            | 5000 (ms)
`secret`                | Private key to send as a parameter of the API request  | Private key from the config file
`remote_ip`             | Optional. The user's IP address, used by hCaptcha     | no default


## Testing

In order to test your endpoints you should set the secret key to the following value in order to receive a positive result from all queries to the Hcaptcha engine.

```
config :hcaptcha,
  secret: "6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe"
```

Setting up tests without network access can be done also. When configured as such a positive or negative result can be generated locally.

```
config :hcaptcha,
  http_client: Hcaptcha.Http.MockClient,
  secret: "6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe"


  {:ok, _details} = Hcaptcha.verify("valid_response")

  {:error, _details} = Hcaptcha.verify("invalid_response")

```

## Contributing

Check out [CONTRIBUTING.md](/CONTRIBUTING.md) if you want to help.

## License

[MIT License](http://www.opensource.org/licenses/MIT).
