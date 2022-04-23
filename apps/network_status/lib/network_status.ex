defmodule NetworkStatus do
  @moduledoc false

  @spec wlan0_address :: :inet.ip_address() | nil
  defdelegate wlan0_address, to: NetworkStatus.WifiAddress
end
