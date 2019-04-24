defmodule HTMLAssertion.MixProject do
  use Mix.Project

  @version "0.1.2"
  @github_url "https://github.com/btbinhtran/html_assertion"

  def project do
    [
      app: :html_assertion,
      version: @version,
      elixir: "~> 1.5",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Assertions for testing rendered HTML.",
      package: package(),
      name: "HTMLAssertion",
      source_url: @github_url,
      docs: docs(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        "coveralls.travis": :test
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:floki, "~> 0.21"},
      {:excoveralls, "~> 0.10", only: :test},
      {:junit_formatter, "~> 3.0", only: :test},
      {:credo, "~> 1.0", only: [:dev, :test]},
      {:dialyxir, "~> 1.0.0-rc.6", only: :dev, runtime: false},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "HTMLAssertion",
      source_ref: "v" <> @version,
      extras: ["README.md", "CHANGELOG.md"],
      source_url: @github_url,
      deps: [Floki: "https://hexdocs.pm/floki/Floki.html"]
    ]
  end

  defp package do
    %{
      files: ~w(lib LICENSE.md mix.exs README.md CHANGELOG.md),
      name: "html_assertion",
      maintainers: ["Binh Tran"],
      links: %{"GitHub" => @github_url},
      licenses: ["MIT"]
    }
  end
end
