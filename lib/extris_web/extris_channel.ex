defmodule ExtrisWeb.ExtrisChannel do
  use Phoenix.Channel
  require Logger

  def join("extris:play", _message, socket) do
    Logger.warn "Someone joined..."
    {:ok, socket}
  end
end
