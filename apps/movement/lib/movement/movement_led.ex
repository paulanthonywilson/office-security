defmodule Movement.MovementLed do
  @moduledoc """
  Turns the led on and off based on movement.
  """
  use GenServer

  alias Circuits.GPIO
  alias Movement.Sensor

  @name __MODULE__
  @pin 27

  def start_link(opts) do
    name = Keyword.get(opts, :name, @name)
    pin = Keyword.get(opts, :pin, @pin)
    GenServer.start_link(__MODULE__, pin, name: name)
  end

  def init(pin) do
    {:ok, led} = GPIO.open(pin, :output, initial_value: 0)
    :ok = Sensor.subscribe()
    {:ok, %{led: led}}
  end

  def handle_info({Movement.Sensor, :movement_detected, _}, %{led: led} = s) do
    GPIO.write(led, 1)
    {:noreply, s}
  end

  def handle_info({Movement.Sensor, :movement_stopped, _}, %{led: led} = s) do
    GPIO.write(led, 0)
    {:noreply, s}
  end

  def handle_info(_, s) do
    {:noreply, s}
  end
end
