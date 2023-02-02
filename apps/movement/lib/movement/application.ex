defmodule Movement.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Movement.Sensor,
      Movement.MovementLed
    ]

    opts = [strategy: :one_for_one, name: Movement.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
