defmodule Fw.MixProject do
  use Mix.Project

  @app :fw
  @version "0.1.0"
  @all_targets [:rpi, :rpi0, :rpi2, :rpi3, :rpi3a, :rpi4, :bbb, :osd32mp1, :x86_64]

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.9",
      archives: [nerves_bootstrap: "~> 1.11"],
      deps_path: "../../deps",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      lockfile: "../../mix.lock",
      start_permanent: Mix.env() == :prod,
      build_embedded: true,
      deps: deps(),
      releases: [{@app, release()}],
      preferred_cli_target: [run: :host, test: :host]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Fw.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Dependencies for all targets
      {:nerves, "~> 1.10", runtime: false},
      {:shoehorn, "~> 0.9.1"},
      {:ring_logger, "~> 0.9"},
      {:toolshed, "~> 0.3.0"},

      # Dependencies for all targets except :host
      {:nerves_runtime, "~> 0.13.3", targets: @all_targets},
      {:nerves_pack, "~> 0.7.0", targets: @all_targets},

      # Dependencies for specific targets
      # NOTE: It's generally low risk and recommended to follow minor version
      # bumps to Nerves systems. Since these include Linux kernel and Erlang
      # version updates, please review their release notes in case
      # changes to your application are needed.
      {:nerves_system_rpi, "~> 1.22.2", runtime: false, targets: :rpi},
      {:nerves_system_rpi0, "~> 1.22.2", runtime: false, targets: :rpi0},

      # debug
      {:recon, "~> 2.5"},

      # under the umbrella

      {:office_sec_web, in_umbrella: true},
      {:movement, in_umbrella: true},
      {:server_comms, in_umbrella: true},

      # extracted
      {:vintage_heart, "~> 0.1.0"},
      {:connectivity_led_status, "~> 0.1.2"},
      {:vintage_net_wizard_launcher, "~> 0.1.0"},
      {:vintage_net_wizard, "~> 0.4.12", targets: @all_targets}
    ]
  end

  def release do
    [
      overwrite: true,
      # Erlang distribution is not started automatically.
      # See https://hexdocs.pm/nerves_pack/readme.html#erlang-distribution
      cookie: "#{@app}_cookie",
      include_erts: &Nerves.Release.erts/0,
      steps: [&Nerves.Release.init/1, :assemble],
      strip_beams: Mix.env() == :prod or [keep: ["Docs"]]
    ]
  end
end
