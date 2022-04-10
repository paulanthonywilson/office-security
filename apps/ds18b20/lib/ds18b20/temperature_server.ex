defmodule Ds18b20.TemperatureServer do
  @moduledoc """
  Periodically read the temperature, and notify subscribers.
  """
  use GenServer

  alias Ds18b20.TemperatureReader

  @devices_base (if Mix.target() == :host do
                   "#{__DIR__}/../../../../fake/ds18b20"
                 else
                   "/sys/bus/w1/devices/"
                 end)

  @name __MODULE__
  @read_every :timer.seconds(60)
  @topic :ds18b20_temperature

  def start_link(opts) do
    device_base = Keyword.get(opts, :device_base, @devices_base)
    use_name? = Keyword.get(opts, :use_name?, true)

    otp_opts = if use_name?, do: [name: @name], else: []

    GenServer.start_link(__MODULE__, device_base, otp_opts)
  end

  @doc """
  Returns the latest temperature in, in an ok tuple, or error
  """
  @spec read(atom | pid) ::
          {:ok, Decimal.t()} | {:error, :bad_one_wire | :enoent | :bad_data, :crc_fail}
  def read(server \\ @name) do
    GenServer.call(server, :read)
  end

  @doc """
  Subcribe to receive notifications of temperature after every reading. Also receives a notification
  on subscription. Events are in the form of
    `{:ds18b20_temperature, {:ok, Decimal.new(21)}}`
  with the second element being any valid return falue of `read/1`
  """
  @spec subscribe(atom | pid) :: :ok
  def subscribe(server \\ @name) do
    Events.subscribe(@topic)
    Events.publish(@topic, read(server))
  end

  def init(device_base) do
    case TemperatureReader.device_file(device_base) do
      {:error, :enoent} ->
        {:ok, %{one_wire_enabled: false}}

      {:ok, device} ->
        schedule_next_read()

        {:ok,
         %{
           one_wire_enabled: true,
           device: device,
           value: TemperatureReader.read_temperature(device)
         }}

      {:error, _} = err ->
        {:ok, %{one_wire_enabled: true, value: err}}
    end
  end

  def handle_info(:read_temperature, %{device: device} = s) do
    schedule_next_read()
    temp = TemperatureReader.read_temperature(device)
    Events.publish(@topic, temp)
    {:noreply, Map.put(s, :value, temp)}
  end

  def handle_call(_, _, %{one_wire_enabled: false} = s) do
    {:reply, {:error, :bad_one_wire}, s}
  end

  def handle_call(:read, _, %{value: value} = s) do
    {:reply, value, s}
  end

  defp schedule_next_read do
    Process.send_after(self(), :read_temperature, @read_every)
  end
end
