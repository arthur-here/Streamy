"use strict";

const port = 5556;
const dgram = require('dgram');
const client = dgram.createSocket('udp4');

client.on('message', function (message, rinfo) {
    console.log('Message from: ' + rinfo.address + ':' + rinfo.port +' - ' + message);
});

client.bind(port, 'localhost');
