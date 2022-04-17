defmodule Movement.MovementSensorTest do
  use ExUnit.Case
  alias Movement.MovementSensor

  describe "movement detection notifications" do
    setup do
      :ok = MovementSensor.subscribe()
    end

    test "broadcasts movement detected" do
      assert {:noreply, %{last_movement: {:movement_detected, %DateTime{}}}} =
               MovementSensor.handle_info({:circuits_gpio, 17, :_, 1}, %{last_movement: nil})

      assert_receive {:movement, {:movement_detected, %DateTime{} = _timestamp}}
    end

    test "no broadcast when movement down" do
      assert {:noreply, %{last_movement: {:movement_stop, %DateTime{}}}} =
               MovementSensor.handle_info({:circuits_gpio, 17, :_, 0}, %{last_movement: nil})

      assert_receive {:movement, {:movement_stop, %DateTime{} = _timestamp}}
    end
  end

  test "subscribe also sends the last event" do
    :ok = MovementSensor.subscribe()
    assert_receive {:movement, _}
  end
end
