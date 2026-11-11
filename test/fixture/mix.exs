defmodule Fixture.MixProject do
  use Mix.Project

  def project do
    [
      app: :fixture,
      version: "0.1.0",
      elixir: "~> 1.18",
      deps: deps(),
      dialyzer: [
        plt_core_path: "priv/plts",
        plt_local_path: "priv/plts"
      ]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:jason, "~> 1.4"},
      # A NIF built with elixir_make, which writes its .so into deps/.
      {:picosat_elixir, "~> 0.2"},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end
end
