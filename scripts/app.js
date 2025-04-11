// server.js
const server = Bun.serve({
    port: 3001,
    fetch(request) {
      return new Response("Hello World");
    }
  });
  
  console.log(`Dummy Server running at http://${server.hostname}:${server.port}`);
  