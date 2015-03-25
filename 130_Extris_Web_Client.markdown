(( make sure nothing's running on port 4000 ))
(( `rm -fr ~/elixir/extris_web` ))

# Episode 130: Extris Web Client

In today's episode, we're going to build a websockets renderer for Extris and a
corresponding bit of JavaScript to support playing Extris on the server from the
browser.  Let's get started.

## Project

We're going to create a new Phoenix application.  Per the guides, this means we
should do the following:

```sh
cd ~/tmp
git clone https://github.com/phoenixframework/phoenix.git && cd phoenix && git checkout v0.7.2 && mix do deps.get, compile
mix phoenix.new extris_web ~/elixir/extris_web
cd ~/elixir/extris_web
mix do deps.get, compile
mix phoenix.start
```

Now if we visit the browser at http://localhost:4000, we can see the getting
started page that tells us our Phoenix application is running successfully.  The
first thing we're going to do is kill the index page template and replace it
with a list of what we want to do this episode.  Open up
web/templates/page/index.html.eex

```html
<h2>Extris</h2>

<ul>
  <li>Get extris game started when websocket connects to channel</li>
  <li>Render board for game in javascript via websockets</li>
  <li>Send game events to game over websockets</li>
</ul>
```

Alright, so now we should get started with the process.  First things first,
let's pull in extris as a dependency:

```elixir
  defp deps do
    [{:phoenix, "~> 0.7.2"},
     {:cowboy, "~> 1.0"},
     {:extris, github: "knewter/extris"}
   ]
  end
```

Go ahead and fetch the dependencies:

```sh
mix deps.get
```

Next, we'll add a channel.  For now, it will just warn us that someone joined
the "play" topic via Logger.

```elixir
defmodule ExtrisWeb.ExtrisChannel do
  use Phoenix.Channel
  require Logger

  def join(socket, "play", _message) do
    Logger.warn "Someone joined..."
    {:ok, socket}
  end
end
```

This channel won't ever get any data if nothing's routed to it, so let's enable
websockets in our router and provide a route for this channel:

```elixir
defmodule ExtrisWeb.Router do
  use Phoenix.Router
  use Phoenix.Router.Socket, mount: "/ws"

  channel "extris", ExtrisWeb.ExtrisChannel

  # ...
end
```

Next, we'll add a bit of JavaScript to connect to this channel when you visit
the index page.  Open up the template:

```html
<h2>Extris</h2>

<ul>
  <li>Get extris game started when websocket connects to channel</li>
  <li>Render board for game in javascript via websockets</li>
  <li>Send game events to game over websockets</li>
</ul>

<script src="/js/phoenix.js"></script>
<script src="/js/extris.js"></script>
```

Then in `priv/static/js/extris.js`:

```javascript
var socket = new Phoenix.Socket("/ws");
socket.join("extris", "play", {}, function(channel){
  console.log("connected...");
});
```

We'll restart the server to make sure our new modules made it in.  Now if you
open the home page in your browser again, you should see something in your js
console as well as in the phoenix logs.

So that's that.  Next, we'll spawn a game for every connection.  Open up the
channel again:

```elixir
defmodule ExtrisWeb.ExtrisChannel do
  use Phoenix.Channel
  require Logger
  @game_interval 500

  def join(socket, "play", _message) do
    Logger.warn "Someone joined..."
    {:ok, game} = Extris.Game.start_link
    :timer.send_interval(@game_interval, game, :tick)
    socket = assign(socket, :game, game)
    Logger.warn "Assigned game #{inspect socket.assigns[:game]}"
    {:ok, socket}
  end
end
```

So now we're spawning the game, sending it the `game_interval` ticks, and
assigning it to the socket so we can fetch the pid again later.  At this point
our tetris game is running but we can't see it.  Let's now build a renderer that
can publish the game board to this socket.  We'll write wishful-thinking code in
this channel to show what we'd like to happen:

```elixir
defmodule ExtrisWeb.ExtrisChannel do
  use Phoenix.Channel
  require Logger
  @game_interval 500

  def join(socket, "play", _message) do
    Logger.warn "Someone joined..."
    {:ok, game} = Extris.Game.start_link
    :timer.send_interval(@game_interval, game, :tick)
    socket = assign(socket, :game, game)
    spawn(fn() -> ExtrisWeb.Websocket.start(game, socket) end)
    Logger.warn "Assigned game #{inspect socket.assigns[:game]}"
    {:ok, socket}
  end
end
```

So we'd like for a Websocket game interaction module (similar to our Wx and SDL
modules) to spawn a process for interacting with the game.  Let's start off by
cloning what was in the Extris.SDL.Window module and renaming things.  Open up
`lib/extris_web/websocket.ex`

```elixir
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
        #ExtrisWeb.Websocket.Renderer.draw(state, socket)
        loop(game, socket)
      event ->
        loop(state, socket)
    end
  end
end
```

Alright, so for now it will just exist and refresh itself 10 times per second,
doing nothing when it ticks.  Let's make sure we don't have any errors.  Restart
everything and try to join again.

Everything seems to be working.  Next, let's implement the websocket renderer.
The Elixir side will just publish the game board to the websocket every time we
tick, for now.  Open up `lib/extris_web/websocket/renderer.ex`:

```elixir
defmodule ExtrisWeb.Websocket.Renderer do
  def draw(state, socket) do
    Phoenix.Channel.reply socket, "extris:board", %{ board: state.board }
  end
end
```

Here we're just replying to the socket with the current game state each time we
get a tick.  We'll also need to uncomment it in ExtrisWeb.Websocket.  You can
see messages streaming in in the js console in your browser.  Next, we'd like to
build a quickie renderer using HTML5's canvas.  Open up the template again and
make a canvas with id 'canvas':

```html
<h2>Extris</h2>

<ul>
  <li>Get extris game started when websocket connects to channel</li>
  <li>Render board for game in javascript via websockets</li>
  <li>Send game events to game over websockets</li>
</ul>

<canvas id="canvas" width="500", height="600">
</canvas>

<script src="/js/phoenix.js"></script>
<script src="/js/extris.js"></script>
```

Now I don't want this to become a sip on javascript, so you can just grab the
extris.js file  from this episode's files and replace your existing
`priv/static/js/extris.js` with it.  We'll also need to handle the inbound
events.  Our js engine sends events down the websocket, so we just need to add a
handler for them in the channel itself:

```elixir
defmodule ExtrisWeb.ExtrisChannel do
  use Phoenix.Channel
  require Logger
  @game_interval 500

  def join(socket, "play", _message) do
    Logger.warn "Someone joined..."
    {:ok, game} = Extris.Game.start_link
    :timer.send_interval(@game_interval, game, :tick)
    socket = assign(socket, :game, game)
    spawn(fn() -> ExtrisWeb.Websocket.start(game, socket) end)
    Logger.warn "Assigned game #{inspect socket.assigns[:game]}"
    {:ok, socket}
  end

  def event(socket, "game_event", message) do
    Extris.Game.handle_input(socket.assigns[:game], String.to_atom(message["event"]))
    socket
  end
end
```

Go ahead and recompile and run it, and we should have a functioning game of
Extris in the browser.  The best part about this is that just spawning a new
browser tab gives you a new game process running on the server.

## Summary

In today's episode, we created a websockets-and-javascript "renderer" for the
Extris game.

Obviously, tetris isn't the greatest game to run this way, since it could all
happen client side.  However, it's pretty trivial from here to start making
multiplayer games where all the cross-client chatter happens on the server, and
very little about the architecture will change for different games.  See you
soon!

## Resources

- [Phoenix](http://www.phoenixframework.org/)
