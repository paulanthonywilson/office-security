defmodule Movement.MovementSensorTest do
  use ExUnit.Case
  alias Movement.MovementSensor

  setup do
    :ok = MovementSensor.subscribe()
  end

  test "broadcasts movement detected" do
    assert {:noreply, %{}} = MovementSensor.handle_info({:circuits_gpio, 17, :_, 1}, %{})
    assert_receive {:movement, :movement_detected}
  end

  test "no broadcast when movement down" do
    assert {:noreply, %{}} = MovementSensor.handle_info({:circuits_gpio, 17, :_, 0}, %{})
    assert_receive {:movement, :movement_stop}
  end
end
