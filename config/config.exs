import Config

# Configures the endpoint
config :office_sec_web, OfficeSecWeb.Endpoint,
  url: [host: "localhost"],
  http: [port: 4000],
  check_origin: false,
  render_errors: [view: OfficeSecWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: OfficeSec.PubSub,
  server: true,
  live_view: [signing_salt: "CG5Tt+3E"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.0",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../apps/office_sec_web/assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :tailwind,
  version: "3.0.12",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../apps/office_sec_web/assets", __DIR__)
  ]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

unless Mix.target() == :host do
  import_config "../apps/fw/config/config.exs"
end

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
