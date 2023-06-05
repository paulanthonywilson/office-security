defmodule ServerComms.RealClient do
  @moduledoc false

  use FedecksClient

  @impl FedecksClient
  def device_id do
    {:ok, hostname} = :inet.gethostname()
    to_string(hostname)
  end

  @connection_url if Mix.target() == :host,
                    do: "ws://localhost:4000/fedecks/websocket",
                    else: "wss://office.merecomp.com/fedecks/websocket"

  @impl FedecksClient
  def connection_url, do: @connection_url
end
