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
    {:ok, %{sensor: sensor, last_movement: nil}}
  end

  @doc """
  Subscribe to receive movement notifications
  """
  def subscribe do
    Events.subscribe(@topic)
    last_movement = GenServer.call(@name, :last_movement)
    Events.send_self(@topic, last_movement)
  end

  def handle_call(:last_movement, _, %{last_movement: last_movement} = s) do
    {:reply, last_movement, s}
  end

  def handle_info({:circuits_gpio, @pin, _, direction}, s) do
    Logger.debug(fn -> "Sensor change: #{direction}" end)
    event = if direction == 1, do: :movement_detected, else: :movement_stop
    last_movement = {event, DateTime.utc_now()}
    Events.publish(@topic, last_movement)
    {:noreply, %{s | last_movement: last_movement}}
  end

  def handle_info(unknown, s) do
    Logger.debug(fn -> "Uknown movement message: #{inspect(unknown)}" end)

    {:noreply, s}
  end
end
