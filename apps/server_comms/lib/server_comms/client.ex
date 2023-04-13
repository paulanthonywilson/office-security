defmodule ServerComms.Client do
  @moduledoc false

  use FedecksClient

  @impl FedecksClient
  def device_id do
    {:ok, hostname} = :inet.gethostname()
    to_string(hostname)
  end

  @impl FedecksClient
  def connection_url, do: "wss://office.merecomp.com/fedecks/websocket"
end
