defmodule Heartbeat.HeartBeatTest do
  use ExUnit.Case

  alias Heartbeat.HeartBeat


  @tag capture_log: true
  test "initialised with empty counts" do
    assert {:ok, %{status: :ok, no_net_count: 0, lan_only_count: 0}} = HeartBeat.init(:_)
  end

  test "resets counters when the VintagetNetWizard hotspot is up" do
    set_ip4({192, 168, 0, 1})
    stub_prop(:lan)

    assert {:noreply, %{status: :ok, no_net_count: 0, lan_only_count: 0}} =
             HeartBeat.handle_info(:check, %HeartBeat{no_net_count: 2, lan_only_count: 2})
  end

  test "resets counters when connected" do
    stub_prop(:internet)

    assert {:noreply, %{status: :ok, no_net_count: 0, lan_only_count: 0}} =
             HeartBeat.handle_info(:check, %HeartBeat{no_net_count: 2, lan_only_count: 2})
  end

  test "increments counters when lan, and ip4 is not the hotspot and not on internet" do
    set_ip4({192, 168, 1, 12})
    stub_prop(:lan)

    assert {:noreply, %{status: :ok, no_net_count: 5, lan_only_count: 3}} =
             HeartBeat.handle_info(:check, %HeartBeat{no_net_count: 4, lan_only_count: 2})
  end

  test "resets lan count, increments no_net_count, and kicks VintageNet on 8th lan_only" do
    stub_prop(:lan)

    assert {:noreply, %{status: :ok, no_net_count: 10, lan_only_count: 0}} =
             HeartBeat.handle_info(:check, %HeartBeat{no_net_count: 9, lan_only_count: 7})

    assert_receive :vintage_net_kicked
  end

  test "is not ok after 28 no_nets" do
    assert {:noreply, %{status: :down}} =
             HeartBeat.handle_info(:check, %HeartBeat{no_net_count: 27, lan_only_count: 2})
  end

  defp set_ip4(addr) do
    addresses = [
      %{
        address: addr,
        family: :inet,
        netmask: {255, 255, 255, 0},
        prefix_length: 24,
        scope: :universe
      },
      %{
        address: {65152, 0, 0, 0, 47655, 60415, 65071, 30543},
        family: :inet6,
        netmask: {65535, 65535, 65535, 65535, 0, 0, 0, 0},
        prefix_length: 64,
        scope: :link
      }
    ]

    stub_prop(["interface", "wlan0", "addresses"], addresses)
  end

  defp stub_prop(property \\ ["interface", "wlan0", "connection"], value) do
    send(self(), {:vn_prop, property, value})
  end
end
