defmodule Hcaptcha.Mixfile do
  use Mix.Project

  def project do
    [
      app: :hcaptcha,
      name: "hcaptcha",
      source_url: "https://github.com/Sebi55/hcaptcha",
      version: "0.0.1",
      elixir: "~> 1.6",
      description: description(),
      deps: deps(),
      package: package(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,

      # Test coverage:
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],

      # Dialyzer:
      dialyzer: [
        plt_add_deps: :apps_direct,
        plt_add_apps: [:jason]
      ]
    ]
  end

  def application do
    [applications: [:logger, :httpoison, :eex]]
  end

  defp description do
    """
    A simple hCaptcha package for Elixir applications, provides verification
    and templates for rendering forms with the hCaptcha widget
    """
  end

  defp deps do
    [
      {:httpoison, ">= 0.12.0"},
      {:jason, "~> 1.0", optional: true},
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "0.19.3", only: :dev},
      {:dialyxir, "~> 0.5", only: [:dev]},
      {:excoveralls, "~> 0.7.1", only: :test}
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Sebastian Grebe"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/Sebi55/hcaptcha", "Forked" => "https://github.com/samueljseay/recaptcha"}
    ]
  end
end
