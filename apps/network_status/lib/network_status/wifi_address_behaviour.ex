defmodule NetworkStatus.WifiAddressBehaviour do
  @moduledoc """
  Seam for getting the WifiAddress in tests.
  """

  @callback wlan0_address :: :inet.ip_address() | nil
  @callback connection_status :: atom()
end
