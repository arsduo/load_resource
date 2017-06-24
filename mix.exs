defmodule LoadResource.Mixfile do
  use Mix.Project

  def project do
    [
      app: :load_resource,
      version: "0.1.0",
      elixir: "~> 1.0",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "LoadResource",
      source_url: "https://github.com/arsduo/load_resource"
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
    A lightweight plug to load and validate resources for incoming requests.
    """
  end

  defp package do
    # These are the default files included in the package
    [
      name: :load_resource,
      files: ["lib", "priv", "mix.exs", "README*", "readme*", "LICENSE*", "license*"],
      maintainers: ["Alex Koppel"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/arsduo/load_resource"}
    ]
  end
end