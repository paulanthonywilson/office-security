defmodule Movement.Occupation do
  @moduledoc """
  Subscribes to movement notification and determines occupancy.
  """
  use GenServer

  @name __MODULE__

  def start_link(opts) do
    name = Keyword.get(opts, :name, @name)

    GenServer.start_link(__MODULE__, %{}, name: name)
  end

  def init(_) do
    {:ok, %{}}
  end


end
