var socket = new Phoenix.Socket("/ws");
var canvas = document.getElementById("canvas");
var ctx = canvas.getContext("2d");

function draw(context, message){
  drawBoard(context, message.board);
}

function drawBoard(context, board){
  var col;
  if(board){
    context.clearRect( 0 , 0 , canvas.width, canvas.height);
    drawFrame(context, board);
    for(i = 0; i < board.length; i++) {
      for(j = 0; j < board[0].length; j++) {
        col = board[i][j];
        switch(col){
          case 0:
            break;
          default:
            drawSquare(context, j, i, brushFor(shapeName(col)));
        }
      }
    }
  }
}

function drawFrame(context, board){
  var brush = brushFor("board");
  var boardWidth = board[0].length;
  var boardHeight = board.length;
  for(x = 0; x < boardWidth; x++){
    drawSquare(context, x, boardHeight, brush);
  }
  for(y = 0; y < boardHeight; y++){
    drawSquare(context, 0, y, brush);
    drawSquare(context, boardWidth, y, brush);
  }
}

function drawSquare(context, x, y, brush){
  var side = 25;
  var trueX = side * x;
  var trueY = side * y
  ctx.fillStyle = brush;
  ctx.fillRect(trueX, trueY, side, side);
}

function brushFor(type){
  switch(type){
    case "board":
      return "rgb(0,0,0)";
    case "ell":
      return "rgb(255, 150, 0)";
    case "jay":
      return "rgb(12, 0, 255)";
    case "ess":
      return "rgb(5, 231, 5)";
    case "zee":
      return "rgb(255, 17, 17)";
    case "bar":
      return "rgb(0, 240, 255)";
    case "oh":
      return "rgb(247, 255, 17)";
    case "tee":
      return "rgb(100, 255, 17)";
  }
}

function shapeName(num){
  switch(num){
    case 1:
      return("ell");
    case 2:
      return("jay");
    case 3:
      return("ess");
    case 4:
      return("zee");
    case 5:
      return("bar");
    case 6:
      return("oh");
    case 7:
      return("tee");
  }
}

socket.join("extris", {}, function(channel){
  console.log("connected...");

  channel.on("board", function(message){
    draw(ctx, message);
  });

  function gameEventFor(evt){
    console.log(evt);
    switch(evt.key){
      case "Up":
        return "rotate_cw";
      case "Left":
        return "move_left";
      case "Right":
        return "move_right";
      default:
        console.log(evt.key);
        return "noop";
    }
  }

  window.onkeyup = function(e){
    e.preventDefault();
    channel.send("game_event", {event: gameEventFor(e)});
    return false;
  }
});
