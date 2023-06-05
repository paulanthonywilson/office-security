defmodule ServerComms.ReportSensors do
  @moduledoc """
  Simple (for now) passing on messages to the server
  """
  use GenServer
  use ServerComms.Client

  @name __MODULE__

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: @name)
  end

  @impl GenServer
  def init(_) do
    Ds18b20.subscribe()
    Movement.subscribe()
    {:ok, %{}}
  end

  @impl GenServer
  def handle_info({:ds18b20_temperature, {:ok, temperature}}, s) do
    Client.send(%{"temperature" => temperature})
    {:noreply, s}
  end

  def handle_info({Movement.Sensor, :movement_detected, datetime}, s) do
    Client.send(%{"movement" => datetime})
    {:noreply, s}
  end

  def handle_info({Movement.Sensor, :movement_stopped, datetime}, s) do
    Client.send(%{"movement_stop" => datetime})
    {:noreply, s}
  end

  def handle_info({Movement.Sensor, :occupied, datetime}, s) do
    Client.send(%{"occupied" => datetime})
    {:noreply, s}
  end

  def handle_info({Movement.Sensor, :unoccupied, datetime}, s) do
    Client.send(%{"unoccupied" => datetime})
    {:noreply, s}
  end

  def handle_info({Client, _}, s), do: {:noreply, s}

  def handle_info(dunno, s) do
    Client.send(%{"unknown" => inspect(dunno)})
    {:noreply, s}
  end
end
