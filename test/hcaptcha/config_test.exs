defmodule HcaptchaConfigTest do
  use ExUnit.Case, async: true

  test "config can read regular config values" do
    Application.put_env(:hcaptcha, :test_var, "test")

    assert Hcaptcha.Config.get_env(:hcaptcha, :test_var) == "test"
  end

  test "config can read environment variables" do
    System.put_env("TEST_VAR", "test_env_vars")
    Application.put_env(:hcaptcha, :test_env_var, {:system, "TEST_VAR"})

    assert Hcaptcha.Config.get_env(:hcaptcha, :test_env_var) ==
             "test_env_vars"
  end
end
