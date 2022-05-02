# credo:disable-for-this-file Credo.Check.Readability.LargeNumbers
defmodule Heartbeat.PulseTest do
  use ExUnit.Case

  alias Heartbeat.Pulse

  @tag capture_log: true
  test "initialised with empty counts" do
    assert {:ok, %{status: :ok, no_net_count: 0, lan_only_count: 0}} = Pulse.init(:_)
  end

  test "resets counters when the VintagetNetWizard hotspot is up" do
    set_ip4({192, 168, 0, 1})
    stub_prop(:lan)

    assert {:noreply, %{status: :ok, no_net_count: 0, lan_only_count: 0, highest_no_net: 4}} =
             Pulse.handle_info(:check, %Pulse{
               no_net_count: 2,
               lan_only_count: 2,
               highest_no_net: 4
             })
  end

  test "no_net and lan_only incremented when no ip" do
    stub_prop(["interface", "wlan0", "addresses"], [])
    stub_prop(:disconnected)

    assert {:noreply, %{status: :ok, no_net_count: 5, lan_only_count: 3}} =
             Pulse.handle_info(:check, %Pulse{no_net_count: 4, lan_only_count: 2})
  end

  test "resets counters when connected" do
    stub_prop(:internet)

    assert {:noreply, %{status: :ok, no_net_count: 0, lan_only_count: 0, highest_no_net: 3}} =
             Pulse.handle_info(:check, %Pulse{
               no_net_count: 2,
               lan_only_count: 2,
               highest_no_net: 3
             })
  end

  test "increments counters when lan, and ip4 is not the hotspot and not on internet" do
    set_ip4({192, 168, 1, 12})
    stub_prop(:lan)

    assert {:noreply, %{status: :ok, no_net_count: 5, lan_only_count: 3}} =
             Pulse.handle_info(:check, %Pulse{no_net_count: 4, lan_only_count: 2})
  end

  test "resets lan count, increments no_net_count, and kicks VintageNet on 24th lan_only" do
    stub_prop(:lan)

    assert {:noreply, %{status: :ok, no_net_count: 41, lan_only_count: 0, last_kick: %DateTime{}}} =
             Pulse.handle_info(:check, %Pulse{no_net_count: 40, lan_only_count: 23})

    assert_receive :vintage_net_kicked
  end

  test "highest_no_net is the highest achieved" do
    assert {:noreply, %{highest_no_net: 4, no_net_count: 3}} =
             Pulse.handle_info(:check, %Pulse{no_net_count: 2, highest_no_net: 4})

    assert {:noreply, %{highest_no_net: 5}} =
             Pulse.handle_info(:check, %Pulse{no_net_count: 4, highest_no_net: 4})
  end

  test "is not ok after 84 no_nets" do
    assert {:noreply, %{status: :down}} =
             Pulse.handle_info(:check, %Pulse{no_net_count: 83, lan_only_count: 2})
  end

  test "status not reset at 85 n_nets" do
    assert {:noreply, %{status: :down}} =
             Pulse.handle_info(:check, %Pulse{no_net_count: 85, lan_only_count: 2, status: :down})
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
