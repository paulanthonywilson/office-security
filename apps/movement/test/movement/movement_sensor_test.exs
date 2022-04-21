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

    test "broadcasts but does not save time when movement stops", %{pid: pid} do
      send(pid, {:circuits_gpio, 17, :_, 0})
      assert_receive {:movement, {:movement_stop, %DateTime{} = _timestamp}}
    end
  end

  test "subscribe also sends the last event if there is one", %{pid: pid} do
    send(pid, {:circuits_gpio, 17, :_, 1})
    :ok = MovementSensor.subscribe(pid)
    assert_receive {:movement, {:movement_detected, _}}
  end

  test "subscribe does not send any events if movement has never been detected", %{pid: pid} do
    :ok = MovementSensor.subscribe(pid)
    refute_receive {:movement, _}
  end

  defp name, do: self() |> inspect() |> String.to_atom()
end
