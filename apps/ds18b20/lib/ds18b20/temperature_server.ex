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

  def start_link(opts) do
    device_base = Keyword.get(opts, :device_base, @devices_base)
    name = Keyword.get(opts, :name, @name)

    GenServer.start_link(__MODULE__, {device_base, name}, name: name)
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
  on subscription. Event messages are in the form of
    `{:ds18b20_temperature, {:ok, Decimal.new(21)}}`
  with the second element being any valid return falue of `read/1`
  """
  @spec subscribe(atom | pid) :: :ok
  def subscribe(server \\ @name) do
    topic = GenServer.call(server, :subscribing)
    SimplestPubSub.subscribe(topic)
  end

  def init({device_base, topic}) do
    state =
      case TemperatureReader.device_file(device_base) do
        {:error, :enoent} ->
          %{one_wire_enabled: false}

        {:ok, device} ->
          schedule_next_read()

          %{
            one_wire_enabled: true,
            device: device,
            value: TemperatureReader.read_temperature(device)
          }

        {:error, _} = err ->
          %{one_wire_enabled: true, value: err}
      end

    {:ok, Map.put(state, :topic, topic)}
  end

  def handle_info(:read_temperature, %{device: device, topic: topic} = s) do
    schedule_next_read()
    temp = TemperatureReader.read_temperature(device)
    SimplestPubSub.publish(topic, event(temp))
    {:noreply, Map.put(s, :value, temp)}
  end

  def handle_call(_, _, %{one_wire_enabled: false} = s) do
    {:reply, {:error, :bad_one_wire}, s}
  end

  def handle_call(:read, _, %{value: value} = s) do
    {:reply, value, s}
  end

  def handle_call(:subscribing, {caller, _}, %{topic: topic, value: value} = s) do
    send(caller, event(value))
    {:reply, topic, s}
  end

  defp schedule_next_read do
    Process.send_after(self(), :read_temperature, @read_every)
  end

  defp event(temperature), do: {:ds18b20_temperature, temperature}
end
