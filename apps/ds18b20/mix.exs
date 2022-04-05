defmodule Ds18b20.MixProject do
  use Mix.Project

  def project do
    [
      app: :ds18b20,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Ds18b20.Application, []}
    ]
  end

  defp deps do
    [
      {:decimal, "~> 2.0"}
    ]
  end
end
