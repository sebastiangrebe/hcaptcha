defmodule HcaptchaTest do
  use ExUnit.Case, async: true

  # see https://docs.hcaptcha.com/#integration-testing-test-keys
  @hcaptcha_test_secret "0x0000000000000000000000000000000000000000"

  test "When the supplied hcaptcha-response is invalid, errors are returned" do
    assert {:error, messages} = Hcaptcha.verify("not_valid")
    assert messages == [:invalid_input_response]
  end

  test "When a valid response is supplied, a success response is returned" do
    assert {:ok, %{challenge_ts: _, hostname: _}} =
             Hcaptcha.verify("10000000-aaaa-bbbb-cccc-000000000001",
               secret: @hcaptcha_test_secret
             )
  end

  test "When an invalid response is supplied, an error response is returned" do
    assert {:error, [:invalid_input_response]} =
             Hcaptcha.verify("invalid_response", secret: @hcaptcha_test_secret)
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
