defmodule LedStatus.SetsLedStatusTest do
  use ExUnit.Case, async: true

  alias LedStatus.{SetsLedStatus, MockOnboardLed, MockWifiAddress}

  import Mox

  setup :verify_on_exit!

  test "when wifi address is set, the Led is turned off" do
    expect(MockWifiAddress, :wlan0_address, fn -> {192, 168, 0, 66} end)
    expect(MockOnboardLed, :turn_off, fn -> :ok end)

    SetsLedStatus.handle_info(:check_addresses, {})
    assert_receive :schedule_next_check
  end

  test "when wifi address is not set, the Led is made to flash alarmingly" do
    expect(MockWifiAddress, :wlan0_address, fn -> nil end)
    expect(MockOnboardLed, :flash_alarmingly, fn -> :ok end)

    SetsLedStatus.handle_info(:check_addresses, {})
    assert_receive :schedule_next_check
  end

  test "when wifi address is VintageNet wizard gateway address then flash languidly" do
    expect(MockWifiAddress, :wlan0_address, fn -> {192, 168, 0, 1} end)
    expect(MockOnboardLed, :flash_languidly, fn -> :ok end)

    SetsLedStatus.handle_info(:check_addresses, {})
    assert_receive :schedule_next_check
  end
end
