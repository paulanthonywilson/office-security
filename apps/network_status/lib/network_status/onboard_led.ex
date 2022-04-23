defmodule NetworkStatus.OnboardLed do
  @moduledoc """
  Turns the Pi Zero Led on or off
  """
  @behaviour NetworkStatus.OnboardLedBehaviour

  @led_addr "led0"

  @impl true
  def flash_alarmingly do
    Nerves.Leds.set(@led_addr, :fastblink)
  end

  @impl true
  def flash_languidly do
    Nerves.Leds.set(@led_addr, :slowblink)
  end

  @impl true
  def turn_off() do
    Nerves.Leds.set(@led_addr, false)
  end

  @impl true
  def flash_heartbeat do
    Nerves.Leds.set(@led_addr, :heartbeat)
  end
end
