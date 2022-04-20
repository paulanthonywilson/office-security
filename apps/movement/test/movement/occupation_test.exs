defmodule Movement.OccupationTest do
  use ExUnit.Case
  alias Movement.Occupation

  setup do
    {:ok, pid} = Occupation.start_link(name: self() |> inspect() |> String.to_atom())
		
    {:ok, pid: pid}
  end

  test "starts unnoccupied", %{pid: pid} do
  end
end
