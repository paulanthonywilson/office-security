defmodule ServerComms.ReportSensors do
  @moduledoc """
  Simple (for now) passing on messages to the server
  """
  use GenServer
  use ServerComms.Client
  alias ServerComms.CameraSend
  require Logger
  @name __MODULE__

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: @name)
  end

  @impl GenServer
  def init(_) do
    Ds18b20.subscribe()
    Movement.subscribe()
    Client.subscribe()
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

  def handle_info({Client, {:message, {:occupation_status, server_status}}}, state) do
    client_status = Movement.occupation()

    case {client_status, server_status} do
      {{false, _ts}, {:unoccupied, server_timestamp}} ->
        Movement.set_occupied(false, server_timestamp)

      {{true, client_timestamp}, {:unoccupied, _}} ->
        Movement.set_occupied(true, client_timestamp)

      {_client, {:occupied, server_timestamp}} ->
        Movement.set_occupied(true, server_timestamp)

      {{client_occupied?, client_timestamp}, :unknown} ->
        Movement.set_occupied(client_occupied?, client_timestamp)
    end

    {:noreply, state}
  end

  def handle_info({Client, {:message, "one-minute-cam"}}, s) do
    CameraSend.start_sending_timed(:timer.minutes(1))
    {:noreply, s}
  end

  def handle_info({Client, _} = message, s) do
    Logger.info(fn -> "Message from server: #{inspect(message)}" end)
    {:noreply, s}
  end

  def handle_info(dunno, s) do
    Client.send(%{"unknown" => inspect(dunno)})
    {:noreply, s}
  end
end
