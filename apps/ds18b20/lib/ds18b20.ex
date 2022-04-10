defmodule Ds18b20 do
  @moduledoc """
  Temperatue reading for`Ds18b20`.
  """

  alias Ds18b20.TemperatureServer

  @doc """
  The latest temperature (refreshed every minute) from
  the Ds18b20 device
  """
  @spec read() :: {:ok, Decimal.t()} | {:error, :bad_one_wire | :enoent | :bad_data, :crc_fail}
  def read do
    TemperatureServer.read()
  end

  @doc """
  Subcribe to receive notifications of temperature after every reading. Also receives a notification
  on subscription. Events are in the form of
    `{:ds18b20_temperature, {:ok, Decimal.new(21)}}`
  with the second element being any valid return falue of `read/1`
  """
  @spec subscribe() :: :ok
  def subscribe do
    TemperatureServer.subscribe()
  end
end
