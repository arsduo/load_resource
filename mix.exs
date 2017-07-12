defmodule LoadResource.Mixfile do
  use Mix.Project

  def project do
    [
      app: :load_resource,
      version: "0.2.0",
      elixir: "~> 1.0",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      package: package(),
      deps: deps(),

      elixirc_paths: ["lib"],

      # Docs
      name: "LoadResource",
      description: description(),
      source_url: "https://github.com/arsduo/load_resource",
      homepage_url: "https://github.com/arsduo/load_resource",
      docs: [
        main: "LoadResource.Plug",
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:plug, "~> 1.3"},
      {:ecto, "~> 2.1"},
      {:postgrex, "~> 0.11", only: [:dev, :test]},
      {:ex_doc, "~> 0.14", only: [:dev, :test]},
      {:credo, "~> 0.8.1", only: [:dev, :test]}
    ]
  end

  defp description do
    """
    A lightweight, flexible plug to load and validate resources used by your app.
    """
  end

  defp package do
    # These are the default files included in the package
    [
      name: :load_resource,
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Alex Koppel"],
      licenses: ["MIT License"],
      links: %{"GitHub" => "https://github.com/arsduo/load_resource"}
    ]
  end
end