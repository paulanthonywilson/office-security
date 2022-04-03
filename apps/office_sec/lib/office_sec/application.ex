defmodule OfficeSec.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the PubSub system
      {Phoenix.PubSub, name: OfficeSec.PubSub}
      # Start a worker by calling: OfficeSec.Worker.start_link(arg)
      # {OfficeSec.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: OfficeSec.Supervisor)
  end
end
