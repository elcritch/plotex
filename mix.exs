defmodule Plotex.MixProject do
  use Mix.Project

  def project do
    [
      app: :plotex,
      version: "0.5.1",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    """
    Extensible plotting library and core plotting routines written in pure Elixir.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*", "test"],
      maintainers: ["Jaremy Creechley"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/elcritch/plotex"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:phoenix_html, ">= 2.13.0"},
      {:calendar, "~> 1.0"},
      {:phoenix_html_helpers, "~> 1.0"},
      {:phoenix_live_view, ">= 0.20.17"}
    ]
  end
end
