defmodule OfficeSecWeb.Router do
  use OfficeSecWeb, :router

  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {OfficeSecWeb.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", OfficeSecWeb do
    pipe_through(:browser)

    live "/", MainLive, :index
  end

  scope "/" do
    pipe_through(:browser)

    live_dashboard("/dashboard", metrics: OfficeSecWeb.Telemetry)
  end

  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through(:browser)
    end
  end
end
