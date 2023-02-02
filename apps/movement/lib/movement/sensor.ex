defmodule Movement.Sensor do
  @moduledoc false
  use HcSr501Occupation.MovementSensor

  @impl HcSr501Occupation.MovementSensor
  def pin, do: 17

  @impl HcSr501Occupation.MovementSensor
  def occupation_timeout, do: :timer.seconds(180)
end
