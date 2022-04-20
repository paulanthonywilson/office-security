defmodule LedStatus.WifiAddress do
  @moduledoc """
  Uses `:inet.getifaddrs/0` to get the IP4 address at `wlan0`. Works on a Pi with Nerves; won't work on OS X (for instance)
  """

  @doc """
  Gets the wlan0 address if it's there
  """
  @behaviour LedStatus.WifiAddressBehaviour

  @impl true
  def wlan0_address do
    with {:ok, addresses} <- :inet.getifaddrs() do
      wlan0_address(addresses)
    end
  end

  @doc false
  @spec wlan0_address(list({charlist(), keyword()})) :: :inet.ip_address() | nil
  def wlan0_address(addresses) do
    addresses
    |> Enum.find(fn {interface, _} -> 'wlan0' == interface end)
    |> extract_ip4_address()
  end


  @impl true
  def connection_status do
   apply(VintageNet, :get, [["interface", "wlan0", "connection"]])
  end

  defp extract_ip4_address({'wlan0', details}) do
    Keyword.get(details, :addr)
  end

  defp extract_ip4_address(_), do: nil
end
