defmodule ExtrisWeb.ExtrisChannel do
  use Phoenix.Channel
  require Logger
  @game_interval 500

  def join("extris", _message, socket) do
    Logger.info "Someone joined..."
    {:ok, game} = Extris.Game.start_link
    :timer.send_interval(@game_interval, game, :tick)
    socket = assign(socket, :game, game)
    spawn(fn() -> ExtrisWeb.Websocket.start(game, socket) end)
    Logger.info "Assigned game #{inspect socket.assigns[:game]}"
    {:ok, socket}
  end

  def handle_in("game_event", msg, socket) do
    Logger.debug "Receiving input: #{inspect msg}"
    socket.assigns[:game]
    |> Extris.Game.handle_input(String.to_atom(msg["event"]))
    {:ok, socket}
  end
end
