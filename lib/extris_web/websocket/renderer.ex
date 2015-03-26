defmodule ExtrisWeb.Websocket.Renderer do
  def draw(state, socket) do
    Phoenix.Channel.reply socket, "board", %{ board: state.board }
  end
end

