defmodule OfficeSecWeb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      OfficeSecWeb.Telemetry,
      # Start the Endpoint (http/https)
      OfficeSecWeb.Endpoint
      # Start a worker by calling: OfficeSecWeb.Worker.start_link(arg)
      # {OfficeSecWeb.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: OfficeSecWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    OfficeSecWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
