var socket = new Phoenix.Socket("/ws");
socket.join("extris:play", {}, function(channel){
  console.log("connected...");
});
