defmodule Camera.FakeCam do
  @moduledoc """
  Returns alternate images of a jumping stick man
  """
  use GenServer
  @behaviour Camera.Cam

  @name __MODULE__

  defstruct images: nil, undisplayed_images: nil
  @type t :: %__MODULE__{images: list(String.t()), undisplayed_images: list(String.t())}

  def start_link(_) do
    GenServer.start_link(__MODULE__, {}, name: @name)
  end

  @impl true
  def init(_) do
    image_dir = Application.app_dir(:camera, "priv/fake_images")
    images = for f <- File.ls!(image_dir), do: File.read!(image_dir <> "/" <> f)
    tick()
    {:ok, %__MODULE__{images: images, undisplayed_images: images}}
  end

  @impl true
  def next_frame() do
    GenServer.call(@name, :fake_image)
  end

  @spec stack_next_image([byte()]) :: :ok
  def stack_next_image(image) do
    GenServer.cast(@name, {:stack_next_image, image})
  end

  @impl true
  def handle_call(:fake_image, _from, %{undisplayed_images: [image | _]} = s) do
    {:reply, image, s}
  end

  @impl true
  def handle_info(:change_image, %{undisplayed_images: [_ | []], images: images} = s) do
    tick()
    {:noreply, %{s | undisplayed_images: images}}
  end

  def handle_info(:change_image, %{undisplayed_images: [_ | rest]} = s) do
    tick()
    {:noreply, %{s | undisplayed_images: rest}}
  end

  @impl true
  def handle_cast({:stack_next_image, image}, %{undisplayed_images: undisplayed_images} = s) do
    {:noreply, %{s | undisplayed_images: [image | undisplayed_images]}}
  end

  defp tick() do
    Process.send_after(self(), :change_image, 1250)
  end
end
