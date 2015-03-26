defmodule ExtrisWeb.Websocket do
  @moduledoc """

  Begin a websocket to render an Extris game

  """

  @refresh_interval 100

  alias Extris.Game

  def start(game, socket) do
    :random.seed(:erlang.now)
    init(game, socket)
  end

  def init(game, socket) do
    :timer.send_interval(@refresh_interval, self, :tick)
    loop(game, socket)
    :erlang.terminate
  end

  def loop(game, socket) do
    state = Game.get_state(game)

    receive do
      :tick ->
        ExtrisWeb.Websocket.Renderer.draw(state, socket)
        loop(game, socket)
      event ->
        loop(state, socket)
    end
  end
end

