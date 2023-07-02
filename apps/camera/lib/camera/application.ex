defmodule Camera.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Camera.Cam.impl()
    ]

    opts = [strategy: :one_for_one, name: Camera.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
