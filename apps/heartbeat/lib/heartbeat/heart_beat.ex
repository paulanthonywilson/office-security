defmodule Heartbeat.HeartBeat do
  @moduledoc """
  Heartbeat.

  * After 28 checks without an internet connection (~ 14 minutes with a 30 second
  check interval) reboots
  * After every 8 checks (4 mins) with only a 'lan' connection (no internet) kicks VintageNet by killing
  `VintageNet.RouteManager`

  All check counts are reset to zero on every heartbeat if the local ip address is 192.168.0.1, ie
  we are running the hotspot for setting up the internet connection.
  """
  use GenServer
  use Heartbeat.VintageNetProperties

  @name __MODULE__
  require Logger

  defstruct lan_only_count: 0, no_net_count: 0

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: @name)
  end

  def check do
    GenServer.call(@name, :check)
  end

  def init(_) do
    if Process.whereis(:heart) do
      :heart.set_callback(__MODULE__, :check)
    else
      Logger.warn("No heartbeat set")
    end

    {:ok, reset()}
  end

  def handle_call(:check, _, s) do
    {health, state} = check(s)
    {:reply, health, state}
  end

  defp check(s) do
    if hotspot?() do
      {:ok, reset()}
    else
      s
      |> check_connection()
      |> check_lan_only_count()
      |> check_ok()
    end
  end

  defp check_connection(%{lan_only_count: lan_count, no_net_count: net_count} = s) do
    if :internet == VintageNetProperties.get(["interface", "wlan0", "connection"]) do
      reset()
    else
      %{s | lan_only_count: lan_count + 1, no_net_count: net_count + 1}
    end
  end

  defp check_lan_only_count(%{lan_only_count: 8} = s) do
    VintageNetProperties.kick()
    %{s | lan_only_count: 0}
  end

  defp check_lan_only_count(s), do: s

  defp check_ok(%{no_net_count: 28} = s), do: {:down, s}

  defp check_ok(s), do: {:ok, s}

  defp reset, do: %__MODULE__{}

  defp hotspot?, do: {192, 168, 0, 1} == ipv4()

  defp ipv4 do
    ["interface", "wlan0", "addresses"]
    |> VintageNetProperties.get()
    |> find_ipv4()
  end

  defp find_ipv4(nil), do: nil

  defp find_ipv4(addresses) do
    addresses
    |> Enum.find(fn %{family: family} -> family == :inet end)
    |> Map.get(:address)
  end
end
