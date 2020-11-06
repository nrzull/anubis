defmodule Anubis.MixProject do
  use Mix.Project

  def project do
    [
      app: :anubis,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:joken, "2.3.0"}
    ]
  end
end
