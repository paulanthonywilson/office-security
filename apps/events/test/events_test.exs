defmodule EventsTest do
  use ExUnit.Case

  test "can subscribe to a topic and receive events on that topic" do
    assert :ok == Events.subscribe(:my_events)
    Events.publish(:my_events, :an_event)
    assert_receive {:my_events, :an_event}
  end

  test "only receives events on topics to which the process has subscribed" do
    assert :ok == Events.subscribe(:my_events)
    Events.publish(:other_event, :an_event)
    refute_receive {:other_event, :an_event}

  end
end
