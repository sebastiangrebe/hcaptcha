defmodule HcaptchaTest do
  use ExUnit.Case, async: true

  # see https://developers.google.com/hcaptcha/docs/faq#id-like-to-run-automated-tests-with-hcaptcha-v2-what-should-i-do
  @hCaptcha_test_secret "0x0000000000000000000000000000000000000000"

  test "When the supplied hcaptcha-response is invalid, multiple errors are returned" do
    assert {:error, messages} = Hcaptcha.verify("not_valid")
    assert messages == [:invalid_input_response, :invalid_input_secret]
  end

  test "When a valid response is supplied, a success response is returned" do
    assert {:ok, %{challenge_ts: _, hostname: _}} =
             Hcaptcha.verify("valid_response", secret: @hCaptcha_test_secret)
  end

  test "When a valid response is supplied, an error response is returned" do
    assert {:error, [:"invalid-input-response"]} =
             Hcaptcha.verify("invalid_response", secret: @hCaptcha_test_secret)
  end

  test "When secret is not overridden the configured secret is used" do
    Hcaptcha.verify("valid_response")

    assert_received {:request_verification,
                     "response=valid_response&secret=test_secret", _}
  end

  test "When the timeout is overridden that config is passed to verify/2 as an option" do
    Hcaptcha.verify("valid_response", timeout: 25_000)

    assert_received {:request_verification, _, [timeout: 25_000]}
  end

  test "Remote IP is used in the request body when it is passed into verify/2 as an option" do
    Hcaptcha.verify("valid_response", remote_ip: "192.168.1.1")

    assert_received {:request_verification,
                     "response=valid_response&secret=test_secret&remote_ip=192.168.1.1",
                     _}
  end

  test "Adding unsupported options does not append them to the request body" do
    Hcaptcha.verify("valid_response", unsupported_option: "not_valid")

    assert_received {:request_verification,
                     "response=valid_response&secret=test_secret", _}
  end
end
