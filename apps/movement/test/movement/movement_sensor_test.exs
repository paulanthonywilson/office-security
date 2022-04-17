defmodule Movement.MovementSensorTest do
  use ExUnit.Case
  alias Movement.MovementSensor

  describe "movement detection notifications" do
    setup do
      :ok = MovementSensor.subscribe()
    end

    test "broadcasts and saves time when movement detected" do
      assert {:noreply, %{last_detected_time: %DateTime{}}} =
               MovementSensor.handle_info({:circuits_gpio, 17, :_, 1}, %{last_detected_time: nil})

      assert_receive {:movement, {:movement_detected, %DateTime{} = _timestamp}}
    end

    test "broadcasts but does not save time" do
      assert {:noreply, %{last_detected_time: nil}} =
               MovementSensor.handle_info({:circuits_gpio, 17, :_, 0}, %{last_detected_time: nil})

      assert_receive {:movement, {:movement_stop, %DateTime{} = _timestamp}}
    end
  end

  test "subscribe also sends the last event" do
    :ok = MovementSensor.subscribe()
    assert_receive {:movement, {:movement_detected, _}}
  end
end
