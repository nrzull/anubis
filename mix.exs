defmodule Anubis.MixProject do
  use Mix.Project

  def project do
    [
      app: :anubis,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Anubis, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:gnat, "1.2.0"},
      {:ecto, "3.5.4"},
      {:ecto_sql, "3.5.3"},
      {:postgrex, "0.15.7"},
      {:jason, "1.2.2"},
      {:joken, "2.3.0"},
      {:bcrypt_elixir, "2.2.0"}
    ]
  end

  defp aliases do
    [
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
