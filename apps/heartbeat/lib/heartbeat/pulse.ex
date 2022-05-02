defmodule Heartbeat.Pulse do
  @moduledoc """
  Heartbeat.

  * Without an internet connection for about 14 minutes with a 30 second check interval) reboots
  * After about 4 mins with only a 'lan' connection (no internet) kicks VintageNet by killing
  `VintageNet.RouteManager`

  All check counts are reset to zero on every heartbeat if the local ip address is 192.168.0.1, ie
  we are running the hotspot for setting up the internet connection.
  """
  use GenServer
  use Heartbeat.VintageNetProperties

  @name __MODULE__
  @poll_interval :timer.seconds(10)
  require Logger

  defstruct lan_only_count: 0, no_net_count: 0, status: :ok, highest_no_net: 0, last_kick: nil

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: @name)
  end

  def status do
    GenServer.call(@name, :status)
  end

  def last_kick do
    GenServer.call(@name, :last_kick)
  end

  def init(_) do
    if Process.whereis(:heart) do
      :heart.set_callback(__MODULE__, :status)
    else
      Logger.info("No heartbeat set")
    end

    Process.send_after(self(), :check, @poll_interval)

    {:ok, %__MODULE__{}}
  end

  def handle_call(:status, _, %{status: status} = s) do
    {:reply, status, s}
  end

  def handle_call(:status, _, %{last_kick: last_kick} = s) do
    {:reply, last_kick, s}
  end

  def handle_info(:check, s) do
    Process.send_after(self(), :check, @poll_interval)
    {:noreply, check(s)}
  end

  defp check(state) do
    if hotspot?() do
      reset_counters(state)
    else
      state
      |> check_connection()
      |> check_lan_only_count()
      |> check_ok()
    end
  end

  defp check_connection(
         %{lan_only_count: lan_count, no_net_count: net_count, highest_no_net: highest_no_net} = s
       ) do
    if :internet == connection_status() do
      reset_counters(s)
    else
      no_net_count = net_count + 1

      %{
        s
        | lan_only_count: lan_count + 1,
          no_net_count: no_net_count,
          highest_no_net: Enum.max([no_net_count, highest_no_net])
      }
    end
  end

  defp reset_counters(state) do
    %{state | lan_only_count: 0, no_net_count: 0}
  end

  defp connection_status do
    VintageNetProperties.get(["interface", "wlan0", "connection"])
  end

  defp check_lan_only_count(%{lan_only_count: 24} = s) do
    VintageNetProperties.kick()
    %{s | lan_only_count: 0, last_kick: DateTime.utc_now()}
  end

  defp check_lan_only_count(s), do: s

  defp check_ok(%{no_net_count: 84} = s), do: %{s | status: :down}

  defp check_ok(s), do: s

  defp hotspot?, do: {192, 168, 0, 1} == ipv4()

  defp ipv4 do
    ["interface", "wlan0", "addresses"]
    |> VintageNetProperties.get()
    |> find_ipv4()
  end

  defp find_ipv4(nil), do: nil

  defp find_ipv4(addresses) do
    addresses
    |> Enum.find(%{}, fn %{family: family} -> family == :inet end)
    |> Map.get(:address)
  end
end
