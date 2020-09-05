import express from "express";
import socketio from "socket.io";
import path from "path";
import { Server } from "http";

const app = express();
app.set("port", process.env.PORT || 3000);

let http = new Server(app);
// set up socket.io and bind it to our
// http server.
let io = socketio(http);

app.get("/", (req: any, res: any) => {
  res.sendFile(path.resolve("./client/index.html"));
});

// whenever a user connects on port 3000 via
// a websocket, log that a user has connected
io.on("connection", (socket) => {
  console.log("a user connected");
  // whenever we receive a 'message' we log it out
  socket.on("message", (message: any) => {
    console.log(message);
  });
});

const server = http.listen(3000, () => {
  console.log("listening on *:3000");
});
