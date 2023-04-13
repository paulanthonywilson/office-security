defmodule ServerCommsTest do
  use ExUnit.Case
  doctest ServerComms

  test "greets the world" do
    assert ServerComms.hello() == :world
  end
end
