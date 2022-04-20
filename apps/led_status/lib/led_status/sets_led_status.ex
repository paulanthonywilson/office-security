defmodule LedStatus.SetsLedStatus do
  @moduledoc """
  Checks to see if there's an IP address assigned to wlan0 every 5 seconds and:

  * if it is not set flashes the onboard LED rapdily
  * if it is set to 192.168.0.1 then assume that this is an access point as part of the configuration
  process, and flash slowly
  * if it is set to soemthing else then turn off the LED

  This could have be done with subscribing to VintageNet but that gets complicated to test
  the different states.
  """

  use GenServer

  @wifi_address if Mix.env() == :test, do: LedStatus.MockWifiAddress, else: LedStatus.WifiAddress
  @onboard_led if Mix.env() == :test, do: LedStatus.MockOnboardLed, else: LedStatus.OnboardLed

  @name __MODULE__

  @five_seconds 5 * 1_000
  @check_every @five_seconds

  @vintagenet_wizard_gateway_ip {192, 168, 0, 1}

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  @impl true
  def init(_) do
    send(self(), :schedule_next_check)
    {:ok, []}
  end

  @impl true
  def handle_info(:check_addresses, state) do
    case @wifi_address.wlan0_address() do
      nil -> @onboard_led.flash_alarmingly()
      @vintagenet_wizard_gateway_ip -> @onboard_led.flash_languidly()
      _ -> check_connection_status()
    end

    send(self(), :schedule_next_check)
    {:noreply, state}
  end

  def handle_info(:schedule_next_check, state) do
    Process.send_after(self(), :check_addresses, @check_every)
    {:noreply, state}
  end

  defp check_connection_status do
    if @wifi_address.connection_status == :internet do
      @onboard_led.turn_off()
    else
      @onboard_led.flash_heartbeat()
    end
  end
end
