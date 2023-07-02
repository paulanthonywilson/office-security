defmodule Camera.RealCam do
  @moduledoc """
  Essentially sits in front of PiCam
  """

  @behaviour Camera.Cam

  @impl true
  def child_spec(_) do
    %{
      id: Picam.Camera,
      start: {Picam.Camera, :start_link, []}
    }
  end

  @impl true
  defdelegate next_frame, to: Picam
end
