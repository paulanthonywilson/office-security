defmodule Movement do
  @moduledoc false

  alias Movement.Sensor

  @doc """
  Get movement and occupation events
  """
  def subscribe do
    Sensor.subscribe()
  end
end
