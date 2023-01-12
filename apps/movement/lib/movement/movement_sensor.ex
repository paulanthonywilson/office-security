defmodule Movement.MovementSensor do
  @moduledoc """
  HC-SR 501 sensor. Pin goes to high for a period when movement is
  detected.


  """
  use GenServer

  alias Circuits.GPIO

  require Logger

  @name __MODULE__

  @pin 17

  def start_link(opts) do
    name = Keyword.get(opts, :name, @name)
    GenServer.start_link(__MODULE__, name, name: name)
  end

  def init(topic) do
    {:ok, sensor} = GPIO.open(@pin, :input)
    :ok = GPIO.set_interrupts(sensor, :both)
    {:ok, %{sensor: sensor, last_detected_time: nil, topic: topic}}
  end

  @doc """
  Subscribe to receive movement notifications
  """
  def subscribe(server \\ @name) do
    topic = GenServer.call(server, :subscribing)
    SimplestPubSub.subscribe(topic)
    :ok
  end

  def handle_call(
        :subscribing,
        {caller, _},
        %{last_detected_time: last_detected_time, topic: topic} = s
      ) do
    if last_detected_time do
      send(caller, event(:movement_detected, last_detected_time))
    end

    {:reply, topic, s}
  end

  def handle_info({:circuits_gpio, @pin, _, 1}, %{topic: topic} = s) do
    Logger.debug("movement detected")
    last_detected_time = DateTime.utc_now()
    SimplestPubSub.publish(topic, event(:movement_detected, last_detected_time))
    {:noreply, %{s | last_detected_time: last_detected_time}}
  end

  def handle_info({:circuits_gpio, @pin, _, 0}, %{topic: topic} = s) do
    Logger.debug("movement detection stop")
    SimplestPubSub.publish(topic, event(:movement_stop, DateTime.utc_now()))
    {:noreply, s}
  end

  def handle_info(unknown, s) do
    Logger.debug(fn -> "Uknown movement message: #{inspect(unknown)}" end)

    {:noreply, s}
  end

  defp event(change_type, timestamp) do
    {:movement, {change_type, timestamp}}
  end
end
