defmodule LedStatus do
  @moduledoc false

  @spec wlan0_address :: :inet.ip_address() | nil
  defdelegate wlan0_address, to: LedStatus.WifiAddress
end
