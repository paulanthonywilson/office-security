defmodule LedStatus.WifiAddressBehaviour do
  @moduledoc """
  Seam for getting the WifiAddress in tests.
  """

  @callback wlan0_address :: :inet.ip_address() | nil
end
