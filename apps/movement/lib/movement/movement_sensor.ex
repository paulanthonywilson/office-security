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
    {:ok, %{sensor: sensor, last_detected_time: nil}}
  end

  @doc """
  Subscribe to receive movement notifications
  """
  def subscribe do
    Events.subscribe(@topic)
    last_detected_time = GenServer.call(@name, :last_detected_time)
    Events.send_self(@topic, {:movement_detected, last_detected_time})
  end

  def handle_call(:last_detected_time, _, %{last_detected_time: last_detected_time} = s) do
    {:reply, last_detected_time, s}
  end

  def handle_info({:circuits_gpio, @pin, _, 1}, s) do
    Logger.debug("movement detected")
    last_detected_time = DateTime.utc_now()
    Events.publish(@topic, {:movement_detected, last_detected_time})
    {:noreply, %{s | last_detected_time: last_detected_time}}
  end

  def handle_info({:circuits_gpio, @pin, _, 0}, s) do
    Logger.debug("movement detection stop")
    Events.publish(@topic, {:movement_stop, DateTime.utc_now()})
    {:noreply, s}
  end

  def handle_info(unknown, s) do
    Logger.debug(fn -> "Uknown movement message: #{inspect(unknown)}" end)

    {:noreply, s}
  end
end
