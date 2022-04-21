defmodule Movement do
  @moduledoc """
  Documentation for `Movement`.
  """
  alias Movement.{MovementSensor, Occupation}

  @doc """
  Get invidual movement detection events
  """
  @spec movement_subscribe :: :ok
  def movement_subscribe do
    MovementSensor.subscribe()
  end

  @doc """
  Get occupation events, when we determine
  the place has become occupied or unoccupied
  """
  @spec movement_subscribe :: :ok
  def occupation_subscribe do
    Occupation.subscribe()
  end
end
