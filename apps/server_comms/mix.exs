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
      {:fedecks_client, git: "git@github.com:paulanthonywilson/fedecks_client.git"}
    ]
  end
end
