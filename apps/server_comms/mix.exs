defmodule ServerComms.MixProject do
  use Mix.Project

  def project do
    [
      app: :server_comms,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {ServerComms.Application, []}
    ]
  end

  defp deps do
    [
      # {:fedecks_client, "~> 0.1.2"},
      {:fedecks_client, path: "../../../fedecks_client"},
      {:ds18b20, git: "git@github.com:paulanthonywilson/ds18b20.git"},
      {:mox, "~> 1.0", only: :test},
      {:movement, in_umbrella: true}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test"]
  defp elixirc_paths(_), do: ["lib"]
end
