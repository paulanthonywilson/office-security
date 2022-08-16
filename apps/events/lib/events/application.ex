defmodule Events.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :duplicate, name: EventsRegistry}
    ]

    opts = [strategy: :one_for_one, name: Events.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
