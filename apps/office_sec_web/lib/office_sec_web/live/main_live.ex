defmodule OfficeSecWeb.MainLive do
  @moduledoc """
  Main local page.
  """

  use OfficeSecWeb, :live_view

  import OfficeSecWeb.EventFormatting

  require Logger

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Ds18b20.subscribe()
      Movement.movement_subscribe()
      Movement.occupation_subscribe()
    end

    {:ok,
     assign(socket,
       temperature: "starting ...",
       last_update: "",
       last_movement: nil,
       occupation: "",
       occupation_time: ""
     )}
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-row mx-auto">
      <div class="basis-1/4"></div>
      <div class="basis-1/6">Current temperature:</div>
      <div class="basis-1/6"><%= format_temperature(@temperature) %> ℃   </div>
    </div>
    <div class="flex flex-row mx-auto">
      <div class="basis-5/12"></div>
      <div class="basis-1/5"><%= format_time(@last_update) %></div>
    </div>
    <div class="flex flex-row mx-auto py-5"></div>
    <div class="flex flex-row mx-auto py-5">
      <div class="basis-1/4"></div>
      <div class="basis-1/6">Last movement</div>
      <div class="basis-1/5"><%= format_date_time(@last_movement) %></div>
    </div>
    <div class="flex flex-row mx-auto">
      <div class="basis-1/4"></div>
      <div class="basis-1/6">Occupied:</div>
      <div class="basis-1/6"><%= @occupation %></div>
    </div>
    <div class="flex flex-row mx-auto">
      <div class="basis-5/12"></div>
      <div class="basis-1/5"><%= format_date_time(@occupation_time) %></div>
    </div>

    """
  end

  def handle_info({:ds18b20_temperature, temperature}, socket) do
    {:noreply, assign(socket, temperature: temperature, last_update: DateTime.utc_now())}
  end

  def handle_info({:movement, {:movement_detected, datetime}}, socket) do
    {:noreply, assign(socket, last_movement: datetime)}
  end

  def handle_info({:occupied, {occupied?, timestamp}}, socket) do
    occupation = if occupied?, do: "Yes", else: "No"
    {:noreply, assign(socket, occupation: occupation, occupation_time: timestamp)}
  end

  def handle_info(event, socket) do
    Logger.debug(fn -> "MainLive event unhandled: #{inspect(event)}" end)
    {:noreply, socket}
  end
end
