defmodule Events do
  @moduledoc """
  Pub sub for events
  """

  @doc """
  Subscribe the current process to receive events
  """
  @spec subscribe(any()) :: :ok
  def subscribe(topic) do
    with {:ok, _} <- Registry.register(EventsRegistry, topic, []) do
      :ok
    end
  end

  @doc """
  Publish an even to any subscribed processes
  Events are sent as messages in the form
  `{topic, event}`
  """
  @spec publish(any, any) :: :ok
  def publish(topic, event) do
    Registry.dispatch(EventsRegistry, topic, fn entries ->
      for {pid, _} <- entries, do: send(pid, {topic, event})
    end)

    :ok
  end
end
