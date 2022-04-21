defmodule Movement.Occupation do
  @moduledoc """
  Subscribes to movement notification and determines occupancy.
  """
  use GenServer

  @name __MODULE__

  defstruct topic: @name, occupied?: false, occupation_timestamp: nil, occupation_timer: nil

  @type t :: %__MODULE__{
          topic: atom(),
          occupied?: boolean(),
          occupation_timestamp: DateTime.t(),
          occupation_timer: reference()
        }

  @occupation_timeout :timer.seconds(180)

  def start_link(opts) do
    name = Keyword.get(opts, :name, @name)

    GenServer.start_link(__MODULE__, name, name: name)
  end

  @doc """
  Well is it?
  """
  def occupied?(server \\ @name) do
    GenServer.call(server, :occupied?)
  end

  def subscribe(server \\ @name) do
    topic = GenServer.call(server, :subscribing)
    Events.subscribe(topic)
  end

  def init(topic) do
    Movement.movement_subscribe()
    {:ok, %__MODULE__{topic: topic, occupation_timestamp: DateTime.utc_now()}}
  end

  def handle_call(:occupied?, _, %{occupied?: result} = s) do
    {:reply, result, s}
  end

  def handle_call(:subscribing, {caller, _}, %{topic: topic} = s) do
    send(caller, occupation_event(s))
    {:reply, topic, s}
  end

  def handle_info(
        {:movement, {:movement_stop, timestamp}},
        %{occupation_timer: existing_timer} = s
      ) do
    if existing_timer, do: Process.cancel_timer(existing_timer)
    timer_ref = Process.send_after(self(), {:occupation_timeout, timestamp}, @occupation_timeout)
    {:noreply, %{s | occupation_timer: timer_ref}}
  end

  def handle_info({:movement, {:movement_detected, _}}, %{occupied?: true} = s) do
    {:noreply, s}
  end

  def handle_info(
        {:movement, {:movement_detected, timestamp}},
        %{occupation_timer: timer_ref, topic: topic} = s
      ) do
    if timer_ref, do: Process.cancel_timer(timer_ref)

    state = %{
      s
      | occupation_timer: nil,
        occupied?: true,
        occupation_timestamp: timestamp
    }

    Events.publish(topic, occupation_event(state))
    {:noreply, state}
  end

  def handle_info({:occupation_timeout, timestamp}, %{topic: topic} = s) do
    state = %{s | occupied?: false, occupation_timer: nil, occupation_timestamp: timestamp}
    Events.publish(topic, occupation_event(state))
    {:noreply, state}
  end

  defp occupation_event(%{occupied?: occupied?, occupation_timestamp: timestamp}) do
    {:occupied, {occupied?, timestamp}}
  end
end
