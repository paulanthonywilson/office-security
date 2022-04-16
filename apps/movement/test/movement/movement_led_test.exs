defmodule Moveement.MovementLedTest do
  use ExUnit.Case, async: false
  alias Circuits.GPIO
  alias Moveement.MovementLed

  setup do
    {:ok, led} = GPIO.open(63, :output)
    on_exit(fn -> GPIO.close(led) end)
    {:ok, led: led}
  end

  test "turns the light on", %{led: led} do
    MovementLed.handle_info({:movement, :movement_detected}, %{led: led})
    assert 1 == GPIO.read(led)
  end

  test "turns the light off", %{led: led} do
    GPIO.write(led, 1)
    MovementLed.handle_info({:movement, :movement_stop}, %{led: led})
    assert 0 == GPIO.read(led)
  end
end
