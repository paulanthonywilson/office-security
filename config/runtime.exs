import Config

unless config_target() == :host do
  config :office_sec_web, OfficeSecWeb.Endpoint,
    http: [port: 80],
    check_origin: false,
    server: true,
    secret_key_base: "L4INDNUVGryF10QAXsAYJfMzkhtWn0xb27e7zICtsYmpZb+Z4psgx6olJeif74en"
end
