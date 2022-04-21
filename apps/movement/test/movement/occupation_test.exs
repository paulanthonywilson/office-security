defmodule Movement.OccupationTest do
  use ExUnit.Case
  alias Movement.Occupation

  @some_time ~U[1970-01-01 00:00:00Z]

  setup do
    {:ok, pid} = Occupation.start_link(name: self() |> inspect() |> String.to_atom())

    {:ok, pid: pid}
  end

  test "starts unnoccupied", %{pid: pid} do
    refute Occupation.occupied?(pid)
  end

  test "initialised without a timeout", %{pid: pid} do
    assert %{occupation_timer: nil} = :sys.get_state(pid)
  end

  test "on movement stop, occupation timer is started", %{pid: pid} do
    send(pid, {:movement, {:movement_stop, @some_time}})
    %{occupation_timer: timer_ref} = :sys.get_state(pid)

    assert Process.read_timer(timer_ref)
  end

  test "on movement detected, occupation timer is cancelled", %{pid: pid} do
    send(pid, {:movement, {:movement_stop, @some_time}})
    %{occupation_timer: timer_ref} = :sys.get_state(pid)

    send(pid, {:movement, {:movement_detected, @some_time}})

    assert %{occupation_timer: nil} = :sys.get_state(pid)

    refute Process.read_timer(timer_ref)
  end

  test "on movement detected, becomes occupied", %{pid: pid} do
    send(pid, {:movement, {:movement_detected, @some_time}})
    assert Occupation.occupied?(pid)
  end

  test "on movement stop, occupation state is unchanged", %{pid: pid} do
    send(pid, {:movement, {:movement_detected, @some_time}})
    send(pid, {:movement, {:movement_stop, @some_time}})

    assert Occupation.occupied?(pid)
  end

  test "on occupation timeout, becomes unoccupied", %{pid: pid} do
    send(pid, {:movement, {:movement_detected, @some_time}})
    send(pid, {:movement, {:movement_stop, @some_time}})
    send(pid, {:occupation_timeout, @some_time})
    refute Occupation.occupied?(pid)
    assert %{occupation_timer: nil} = :sys.get_state(pid)
  end

  test "receives occupation state on subscription, when occupied", %{pid: pid} do
    timestamp = ~U[2011-01-01 01:02:03Z]
    send(pid, {:movement, {:movement_detected, timestamp}})
    Occupation.subscribe(pid)
    assert_receive {:occupied, {true, ^timestamp}}
  end

  test "on occupation, sends event with timestamp of the movement_detected", %{pid: pid} do
    timestamp = ~U[2011-01-01 01:02:03Z]
    Occupation.subscribe(pid)
    send(pid, {:movement, {:movement_detected, timestamp}})

    assert_receive {:occupied, {true, ^timestamp}}
  end

  test "on becoming unoccupied, the timestamp is that the occupation stopped", %{pid: pid} do
    timestamp = ~U[2011-01-01 01:02:03Z]
    send(pid, {:occupation_timeout, timestamp})
    Occupation.subscribe(pid)
    assert_receive {:occupied, {false, ^timestamp}}
  end

  test "subscribed processes get notifications", %{pid: pid} do
    Occupation.subscribe(pid)
    assert_receive {:occupied, _}
    occupation_timestamp = ~U[2021-01-01 01:02:03Z]

    send(pid, {:movement, {:movement_detected, occupation_timestamp}})
    assert_receive {:occupied, {true, ^occupation_timestamp}}

    unoccupied_timestamp = ~U[2021-01-01 02:02:03Z]
    send(pid, {:occupation_timeout, unoccupied_timestamp})
    assert_receive {:occupied, {false, ^unoccupied_timestamp}}
  end
end
