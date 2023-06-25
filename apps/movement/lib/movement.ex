defmodule Movement do
  @moduledoc false

  alias Movement.Sensor

  @doc """
  Get movement and occupation events
  """
  @spec subscribe :: :ok
  def subscribe do
    Sensor.subscribe()
  end

  defdelegate set_occupied(occupied?, timestamp), to: Sensor
  defdelegate occupation, to: Sensor
end
