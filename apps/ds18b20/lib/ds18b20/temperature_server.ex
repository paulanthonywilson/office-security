defmodule Ds18b20.TemperatureServer do
  @moduledoc """
  Periodically read the temperature, and notify subscribers.
  """
  use GenServer

  alias Ds18b20.TemperatureReader

  @devices_base (if Mix.target() == :host do
                   "../../fake/ds18b20"
                 else
                   "/sys/bus/w1/devices/"
                 end)

  @name __MODULE__
  @read_every :timer.seconds(60)
  def start_link(opts) do
    device_base = Keyword.get(opts, :device_base, @devices_base)
    use_name? = Keyword.get(opts, :use_name?, true)

    otp_opts = if use_name?, do: [name: @name], else: []

    GenServer.start_link(__MODULE__, device_base, otp_opts)
  end

  def read(server \\ @name) do
    GenServer.call(server, :read)
  end

  def init(device_base) do
    case TemperatureReader.device_file(device_base) do
      {:error, :enoent} ->
        {:ok, %{one_wire_enabled: false}}

      {:ok, device} ->
        send(self(), :read_temperature)
        {:ok, %{one_wire_enabled: true, device: device, value: {:ok, Decimal.new("-273.15")}}}

      {:error, _} = err ->
        {:ok, %{one_wire_enabled: true, value: err}}
    end
  end

  def handle_info(:read_temperature, %{device: device} = s) do
    Process.send_after(self(), :read_temperature, @read_every)
    temp = TemperatureReader.read_temperature(device)
    {:noreply, Map.put(s, :value, temp)}
  end

  def handle_call(_, _, %{one_wire_enabled: false} = s) do
    {:reply, {:error, :bad_one_wire}, s}
  end

  def handle_call(:read, _, %{value: value} = s) do
    {:reply, value, s}
  end
end
