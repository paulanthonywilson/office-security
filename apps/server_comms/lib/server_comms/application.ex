defmodule ServerComms.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ServerComms.Client,
      ServerComms.ReportSensors
    ]

    opts = [strategy: :one_for_one, name: ServerComms.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
