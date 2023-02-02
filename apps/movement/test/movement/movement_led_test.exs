defmodule Movement.MovementLedTest do
  use ExUnit.Case, async: false
  alias Circuits.GPIO
  alias Movement.MovementLed

  @a_date_time ~U[2022-11-10 09:08:07Z]

  setup do
    {:ok, led} = GPIO.open(63, :output)
    on_exit(fn -> GPIO.close(led) end)
    {:ok, led: led}
  end

  test "turns the light on", %{led: led} do
    MovementLed.handle_info({Movement.Sensor, :movement_detected, @a_date_time}, %{led: led})
    assert 1 == GPIO.read(led)
  end

  test "turns the light off", %{led: led} do
    GPIO.write(led, 1)
    MovementLed.handle_info({Movement.Sensor, :movement_stopped, @a_date_time}, %{led: led})
    assert 0 == GPIO.read(led)
  end
end
