defmodule Ds18b20 do
  @moduledoc """
  Temperatue reading for`Ds18b20`.
  """

  alias Ds18b20.TemperatureServer

  @doc """
  The latest temperature (refreshed every minute) from
  the Ds18b20 device
  """
  def read do
    TemperatureServer.read()
  end
end
