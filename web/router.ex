defmodule ExtrisWeb.Router do
  use Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ExtrisWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  socket "/ws", ExtrisWeb do
    channel "extris", ExtrisChannel
  end
end
