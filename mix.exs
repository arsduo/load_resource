defmodule LoadResource.Mixfile do
  use Mix.Project

  def project do
    [
      app: :load_resource,
      version: "0.1.0",
      elixir: "~> 1.0",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      package: package(),
      deps: deps(),

      elixirc_paths: elixirc_paths(Mix.env),

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
    # These are neceessary to run our tests
    [applications: [:ecto]]
  end

  defp deps do
    [
      {:plug, "~> 1.3"},
      {:ecto, "~> 2.1"},
      {:ex_doc, "~> 0.14", only: :dev},
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

  # When running in test, include the test repo and other support files
  # See https://stackoverflow.com/questions/39146331/how-load-files-in-a-path-different-than-lib-elixir
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]
end