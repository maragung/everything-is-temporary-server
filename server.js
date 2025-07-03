import { Server } from "socket.io";
import { createServer } from "http";

const httpServer = createServer();

const io = new Server(httpServer, {
  cors: {
    // Izinkan koneksi dari frontend Vercel Anda.
    // Ganti dengan domain Vercel Anda setelah deploy, contoh: "https://your-vercel-app.vercel.app"
    origin: "*", // Untuk pengembangan, Anda bisa menggunakan "*" atau domain frontend Anda
    methods: ["GET", "POST"]
  }
});

io.on("connection", (socket) => {
  console.log(`[Socket.IO] User connected: ${socket.id}`);

  socket.on("join-room", ({ roomId, nickname }) => {
    socket.join(roomId);
    console.log(`[Socket.IO] ${nickname} joined room: ${roomId}`);
    io.to(roomId).emit("receive-notice", `${nickname} joined the room`);
  });

  socket.on("send-message", ({ roomId, from, text, file }) => {
    console.log(`[Socket.IO] Message from ${from} in room ${roomId}`);
    io.to(roomId).emit("receive-message", { from, text, file });
  });

  socket.on("leave-room", ({ roomId, nickname }) => {
    socket.leave(roomId);
    console.log(`[Socket.IO] ${nickname} left room: ${roomId}`);
    io.to(roomId).emit("receive-notice", `${nickname} left the room`);
  });

  socket.on("disconnect", () => {
    console.log(`[Socket.IO] User disconnected: ${socket.id}`);
  });
});


const PORT = process.env.PORT || 3001;
httpServer.listen(PORT, () => {
  console.log(`[Socket.IO] Server listening on port ${PORT}`);
});
