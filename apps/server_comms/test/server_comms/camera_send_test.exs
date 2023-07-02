defmodule ServerComms.CameraSendTest do
  use ExUnit.Case, async: false
  alias ServerComms.CameraSend
  import Mox

  setup :verify_on_exit!

  setup do
    {:ok, pid} = start_supervised(CameraSend)
    test_pid = self()

    stub(MockFedecksClient, :send_raw, fn _ ->
      # Can't fully control how often images might get sent in a test
      # so we'll just send a message to the test stub
      send(test_pid, :message_sent)

      :ok
    end)

    allow(MockFedecksClient, self(), pid)
    {:ok, pid: pid}
  end

  test "sends images to the client" do
    CameraSend.start_sending_timed(1_000)
    assert_receive :message_sent
  end

  test "sends an image at roughly 10fps" do
    CameraSend.start_sending_timed(1_000)
    assert_receive :message_sent
    assert_receive :message_sent, 500
  end

  test "sets timer to stop sending after the time" do
    CameraSend.start_sending_timed(:timer.minutes(1))
    assert %{stop_sending_timer: stop_sending_timer_ref} = :sys.get_state(CameraSend)
    assert Process.read_timer(stop_sending_timer_ref) > :timer.seconds(58)
    assert Process.read_timer(stop_sending_timer_ref) < :timer.seconds(61)
  end

  test "does stop sending" do
    CameraSend.start_sending_timed(1)

    assert_receive :message_sent
    refute_receive :message_sent, 200
  end
end
