defmodule LedStatus.OnboardLedBehaviour do
  @moduledoc """
  Behaviour for turning on and off the onboard LED of a Pi Zero, addressed as "led0".

  Defined as a behaviour to provide a testing seam
  """

  @doc """
  Sets the LED to flash rapidly
  """
  @callback flash_alarmingly :: :ok

  @doc """
  Sets the LED to flash slowly
  """
  @callback flash_languidly :: :ok

  @doc """
  You'll never guess what this does.
  """
  @callback turn_off :: :ok

  @doc """
  Two rapid flashes, then a pause etc...
  """
  @callback flash_heartbeat :: :ok
end
