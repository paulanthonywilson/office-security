defmodule CameraTest do
  use ExUnit.Case
  doctest Camera

  test "greets the world" do
    assert Camera.hello() == :world
  end
end
