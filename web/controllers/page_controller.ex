defmodule ExtrisWeb.PageController do
  use ExtrisWeb.Web, :controller

  plug :action

  def index(conn, _params) do
    render conn, "index.html"
  end
end
