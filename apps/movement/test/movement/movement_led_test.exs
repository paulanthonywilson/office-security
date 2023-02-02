defmodule Movement.MovementLedTest do
  use ExUnit.Case, async: false
  alias Circuits.GPIO
  alias Movement.MovementLed

  @a_date_time ~U[2022-11-10 09:08:07Z]

  setup do
    unique_name = self() |> inspect() |> String.to_atom()
    {:ok, pid} = MovementLed.start_link(pin: 0, name: unique_name)
    {:ok, outpin} = GPIO.open(1, :output)

    {:ok, pid: pid, outpin: outpin}
  end

  test "turns the light on", %{outpin: outpin, pid: pid} do
    send(pid, {Movement.Sensor, :movement_detected, @a_date_time})
    process_message_queue(pid)
    assert 1 == GPIO.read(outpin)
  end

  test "turns the light off", %{outpin: outpin, pid: pid} do
    send(pid, {Movement.Sensor, :movement_detected, @a_date_time})
    send(pid, {Movement.Sensor, :movement_stopped, @a_date_time})
    process_message_queue(pid)
    assert 0 == GPIO.read(outpin)
  end

  defp process_message_queue(pid) do
    :sys.get_state(pid)
  end
end
