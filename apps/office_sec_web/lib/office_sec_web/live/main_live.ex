defmodule OfficeSecWeb.MainLive do
  @moduledoc """
  Main local page.
  """

  use OfficeSecWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Ds18b20.subscribe()
    end

    {:ok, assign(socket, temperature: "starting ...")}
  end

  def render(assigns) do
    ~H"""
    <h1> Yay, live</h1>
    <p>Temp: <%= format_temperature(@temperature) %> </p>
    """
  end

  defp format_temperature({:ok, %Decimal{} = temp}) do
    temp
    |> Decimal.round(1)
    |> Decimal.to_string()
  end

  defp format_temperature({:error, reason}) do
    inspect(reason)
  end

  defp format_temperature(message) when is_binary(message) do
    message
  end

  def handle_info({:ds18b20_temperature, temperature}, socket) do
    {:noreply, assign(socket, temperature: temperature)}
  end

  def handle_info(event, socket) do
    IO.inspect(event, label: :handle_info)
    {:noreply, socket}
  end
end
