"use strict";

const net = require('net');
const http = require('http');
const fs = require('fs');
const url = require('url');
const StringDecoder = require('string_decoder').StringDecoder;
const bsplit = require('buffer-split');

// HTTP Server

const httpServer = http.createServer((request, response) => {
  const path = url.parse(request.url).pathname;

  switch(path) {
    case '/':
    case '/index.html':
      fs.readFile(__dirname + '/index.html', (error, data) => {
        if (error) {
          console.log(error);
          response.writeHead(404);
          response.write("oops, this doens't exist - 404");
          response.end();
        } else {
          response.writeHead(200, {'Content-Type': 'text/html'});
          response.write(data, 'utf8');
          response.end();
        }
      });
      break;
    case '/image.jpg':
      fs.readFile(__dirname + path, (error, data) => {
        if (error) {
          console.log(error);
          response.writeHead(404);
          response.write("oops, this doens't exist - 404");
          response.end();
        } else {
          let options = {
            'Content-Type': 'image/jpg',
            'Cache-Control':'no-cache, no-store, must-revalidate',
            "Pragma": "no-cache",
            "Expires": "0"
          };
          response.writeHead(200, options);
          response.write(data, 'binary');
          response.end();
        }
      });
      break;
    default:
      console.log(path);
      response.writeHead(404);
      response.write("oops, this doens't exist - 404");
      response.end();
  }
});
httpServer.listen(8000);

const io = require('socket.io').listen(httpServer);

io.sockets.on('connection', function(socket) {

});

// TCP server

const host = 'localhost';
const port = '8001';

var buffer = new Buffer(0, 'binary');

net.createServer(socket => {

  socket.name = socket.remoteAddress + ":" + socket.remotePort;

  socket.on("data", data => {

    buffer = Buffer.concat([buffer, new Buffer(data,'binary')]);

    if (data.toString('utf8').indexOf("end_of_frame") !== -1) {

      let result = bsplit(buffer, new Buffer("end_of_frame"));
      let imageBuffer = result[0];
      buffer = result[1] || new Buffer(0, "binary");

      // io.sockets.emit('image', { image: true, buffer: imageBuffer.toString("base64") });
      fs.writeFile("image.jpg", imageBuffer, (err, saved) => {
        io.sockets.emit("image_update");
        if (err) console.log(err);
      });
    }
  });

  socket.on("end", () => {
    console.log("Did recived fin packet");
  });

  socket.on("error", error => {
    console.log("Unhandled error: " + error);
  });
}).listen(port, host, () => {
  console.log('TCP Server listening on ' + host + ':' + port);
});
