defmodule Hcaptcha.Mixfile do
  use Mix.Project

  def project do
    [
      app: :hcaptcha,
      name: "hcaptcha",
      source_url: "https://github.com/A-World-For-Us/hcaptcha",
      version: "0.1.0",
      elixir: "~> 1.15",
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
        list_unused_filters: true,
        # Put the project-level PLT in the priv/ directory (instead of the default _build/ location)
        # for the CI to be able to cache it between builds
        plt_local_path: "priv/plts/project.plt",
        plt_core_path: "priv/plts/core.plt",
        # Add `:mix` to the list of apps to include in the PLT, allowing dialyzer to
        # know about the `Mix` functions and `Mix.Task` behaviour
        plt_add_apps: [:mix, :iex]
      ]
    ]
  end

  def cli do
    [
      preferred_envs: [
        dialyzer: :test
      ]
    ]
  end

  defp description do
    """
    A simple hCaptcha package for Elixir applications, provides verification
    and templates for rendering forms with the hCaptcha widget
    """
  end

  defp deps do
    [
      {:httpoison, "~> 2.1"},
      {:jason, "~> 1.4", optional: true},
      {:credo, "~> 1.7.1", only: [:dev, :test], runtime: false},
      {:ex_doc, "0.37.0", only: :dev},
      {:dialyxir, "~> 1.4.1", only: [:test], runtime: false},
      {:excoveralls, "~> 0.18.3", only: :test}
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Antoine Bolvy"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/Sebi55/hcaptcha",
        "Forked" => "https://github.com/samueljseay/recaptcha"
      }
    ]
  end
end
