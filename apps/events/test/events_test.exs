defmodule EventsTest do
  use ExUnit.Case

  test "can subscribe to a topic and receive events on that topic" do
    assert :ok == Events.subscribe(:my_events)
    Events.publish(:my_events, :an_event)
    assert_receive {:my_events, :an_event}
  end

  test "receives one, and only one, notification per publication" do
    :ok = Events.subscribe(:my_events)
    Events.publish(:my_events, :an_event)
    assert_receive {:my_events, :an_event}
    refute_receive {:my_events, :an_event}
  end

  test "only receives events on topics to which the process has subscribed" do
    :ok = Events.subscribe(:my_events)
    Events.publish(:other_event, :an_event)
    refute_receive {:other_event, :an_event}
  end

  test "send_self, sends a topic message only to the calling  process" do
    :ok = Events.subscribe(:my_events)

    task =
      Task.async(fn ->
        assert :ok == Events.send_self(:my_events, :private_event)
        assert_receive {:my_events, :private_event}
      end)

    Task.await(task)
    refute_receive {:my_events, :private_event}
  end
end
