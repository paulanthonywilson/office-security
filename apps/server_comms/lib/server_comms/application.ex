defmodule ServerComms.Application do
  @moduledoc false

  use Application

  @mix_env Mix.env()

  @impl true
  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: ServerComms.Supervisor]
    Supervisor.start_link(children(), opts)
  end

  case Mix.env() do
    :test ->
      defp children, do: []

    _ ->
      defp children do
        [
          ServerComms.Client,
          ServerComms.ReportSensors,
          ServerComms.CameraSend
        ]
      end
  end
end
