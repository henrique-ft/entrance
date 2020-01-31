defmodule Entrance.Mixfile do
  use Mix.Project

  def project do
    [
      app: :entrance,
      version: "0.2.0",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: "Easy, secure and flexible authentication for Plug / Phoenix projects.",
      package: package(),
      docs: [extras: ["README.md"], main: "readme"],
      deps: deps()
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:bcrypt_elixir, "~> 2.1"},
      {:ecto, "~> 3.3"},
      {:plug, "~> 1.8"},
      {:earmark, "~> 1.4", only: :dev},
      {:ex_doc, "~> 0.21.2", only: :dev}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support", "test"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      name: :entrance,
      maintainers: ["Henrique Fernandez Teixeira"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/henriquefernandez/entrance"}
    ]
  end
end
