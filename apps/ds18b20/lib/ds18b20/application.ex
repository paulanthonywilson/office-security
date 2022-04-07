defmodule Ds18b20.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Ds18b20.TemperatureServer
    ]

    opts = [strategy: :one_for_one, name: Ds18b20.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
