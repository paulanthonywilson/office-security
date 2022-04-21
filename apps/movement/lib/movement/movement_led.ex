defmodule Movement.MovementLed do
  @moduledoc """
  Turns the led on and off based on movement.
  """
  use GenServer

  alias Circuits.GPIO
  alias Movement.MovementSensor

  @name __MODULE__
  @pin 27

  def start_link(_) do
    GenServer.start_link(__MODULE__, {}, name: @name)
  end

  def init(_) do
    {:ok, led} = GPIO.open(@pin, :output)
    :ok = MovementSensor.subscribe()
    {:ok, %{led: led}}
  end

  def handle_info({:movement, :movement_detected}, %{led: led} = s) do
    GPIO.write(led, 1)
    {:noreply, s}
  end

  def handle_info({:movement, :movement_stop}, %{led: led} = s) do
    GPIO.write(led, 0)
    {:noreply, s}
  end

  def handle_info(_, s) do
    {:noreply, s}
  end
end
