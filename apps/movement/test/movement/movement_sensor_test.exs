defmodule Movement.MovementSensorTest do
  use ExUnit.Case
  alias Movement.MovementSensor

  setup do
    {:ok, pid} = MovementSensor.start_link(name: name())
    {:ok, pid: pid}
  end

  describe "movement detection notifications" do
    setup %{pid: pid} do
      :ok = MovementSensor.subscribe(pid)
    end

    test "broadcasts and saves time when movement detected", %{pid: pid} do
      send(pid, {:circuits_gpio, 17, :_, 1})
      assert_receive {:movement, {:movement_detected, %DateTime{} = _timestamp}}
    end

    test "broadcasts but does not save time when movement stops" do
      assert {:noreply, %{last_detected_time: nil}} =
               MovementSensor.handle_info({:circuits_gpio, 17, :_, 0}, %{last_detected_time: nil})

      assert_receive {:movement, {:movement_stop, %DateTime{} = _timestamp}}
    end
  end

  test "subscribe also sends the last event" do
    :ok = MovementSensor.subscribe()
    assert_receive {:movement, {:movement_detected, _}}
  end

  defp name, do: self() |> inspect() |> String.to_atom()
end
