defmodule Movement.MovementSensor do
  @moduledoc """
  HC-SR 501 sensor. Pin goes to high for a period when movement is
  detected.


  """
  use GenServer

  alias Circuits.GPIO

  require Logger

  @name __MODULE__
  @topic :movement

  @pin 17

  def start_link(_) do
    GenServer.start_link(__MODULE__, {}, name: @name)
  end

  def init(_) do
    {:ok, sensor} = GPIO.open(@pin, :input)
    :ok = GPIO.set_interrupts(sensor, :both)
    {:ok, %{sensor: sensor}}
  end

  @doc """
  Subscribe to receive movement notifications
  """
  def subscribe do
    Events.subscribe(@topic)
  end

  def sensor_ref do
    GenServer.call(@name, :sensor_ref)
  end

  def handle_call(:sensor_ref, _, %{sensor: sensor} = s) do
    {:reply, sensor, s}
  end

  def handle_info({:circuits_gpio, @pin, _, direction}, s) do
    Logger.debug(fn -> "Sensor change: #{direction}" end)
    handle_sensor_state_change(direction)
    {:noreply, s}
  end

  def handle_info(unknown, s) do
    Logger.debug(fn -> "Uknown movement message: #{inspect(unknown)}" end)

    {:noreply, s}
  end

  defp handle_sensor_state_change(1) do
    Events.publish(@topic, :movement_detected)
  end

  defp handle_sensor_state_change(0) do
    Events.publish(@topic, :movement_stop)
  end
end
