defmodule Movement.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Movement.MovementSensor,
      Movement.MovementLed,
      Movement.Occupation
    ]

    opts = [strategy: :one_for_one, name: Movement.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
