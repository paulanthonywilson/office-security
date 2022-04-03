import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :office_sec_web, OfficeSecWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "ZbQlw5F5JC0kITQlkBt568fyoxrMn+xZiaQZBM0cHr6NKbh42U4SwUSFEK+tKask",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
