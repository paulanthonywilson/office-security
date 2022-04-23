defmodule Heartbeat.FakeVintageNetProperties do
  @moduledoc false

  @behaviour Heartbeat.VintageNetProperties
  @doc """
  If the current process has a message with
  `{:vn_prop, property, value}` then value is returned
  else nil
  """
  @impl true
  def get(property) do
    receive do
      {:vn_prop, ^property, value} -> value
    after
      1 -> nil
    end
  end

  @impl true
  @doc """
  Sends :vintage_net_kicked to the current process
  """
  def kick do
    send(self(), :vintage_net_kicked)
  end
end
