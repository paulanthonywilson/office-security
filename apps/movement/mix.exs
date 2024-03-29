defmodule Movement.MixProject do
  use Mix.Project

  def project do
    [
      app: :movement,
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

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Movement.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:hc_sr_501_occupation, "~> 0.1.3"},
      {:simplest_pub_sub, "~> 0.1.0"}
    ]
  end
end
