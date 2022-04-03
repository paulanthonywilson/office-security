defmodule OfficeSecWeb.PageController do
  use OfficeSecWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
