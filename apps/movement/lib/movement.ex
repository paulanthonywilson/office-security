defmodule Movement do
  @moduledoc """
  Documentation for `Movement`.
  """
  alias Movement.MovementSensor

  @doc """

  """
  def movement_subscribeh do
    MovementSensor.subscribe()
  end
end
