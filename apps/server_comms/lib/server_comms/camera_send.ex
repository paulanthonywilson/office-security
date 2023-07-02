defmodule ServerComms.CameraSend do
  @moduledoc """
  Sends images up to the server
  """
  use GenServer
  use ServerComms.Client

  @name __MODULE__

  @fps 10

  @send_every 1 |> :timer.seconds() |> Integer.floor_div(@fps)

  defstruct [:stop_sending_timer, :next_send_timer]

  def start_link(_) do
    GenServer.start_link(__MODULE__, {}, name: @name)
  end

  @impl GenServer
  def init(_) do
    {:ok, %__MODULE__{}}
  end

  def start_sending_timed(for_milliseconds) do
    GenServer.cast(@name, {:start_sending_timed, for_milliseconds})
  end

  @impl GenServer
  def handle_cast({:start_sending_timed, for_milliseconds}, state) do
    stop_sending_timer = Process.send_after(self(), :stop_sending, for_milliseconds)
    send(self(), :send)

    {:noreply, %{state | stop_sending_timer: stop_sending_timer}}
  end

  @impl GenServer
  def handle_info(:send, state) do
    next_send_timer = Process.send_after(self(), :send, @send_every)

    Camera.next_frame()
    |> Client.send_raw()

    {:noreply, %{state | next_send_timer: next_send_timer}}
  end

  def handle_info(:stop_sending, %{next_send_timer: next_send_timer} = state) do
    if next_send_timer, do: Process.cancel_timer(next_send_timer)
    {:noreply, state}
  end
end
