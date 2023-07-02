defmodule Camera.Cam do
  @moduledoc """
  Either the PiCam or a fake one. In this case the implementation depends on the target to allow
  us to use the fake camera locally. It's not a testing seam.
  """

  @callback next_frame() :: [byte]
  @callback child_spec(any()) :: map()

  @implementation if Mix.target() in [:host, :elixir_ls], do: Camera.FakeCam, else: Camera.RealCam

  def impl(), do: @implementation
end
