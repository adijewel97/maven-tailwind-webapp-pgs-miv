// livereload-server.js
const livereload = require("livereload");

// Buat server LiveReload
const server = livereload.createServer({
  exts: ["html", "jsp", "css", "js"], // file yang dipantau
  delay: 100                          // delay kecil biar stabil
});

// Pantau folder webapp (semua JSP, CSS, JS)
server.watch(__dirname + "/src/main/webapp");

console.log("✅ Livereload server listening on port 35729, watching /src/main/webapp");

