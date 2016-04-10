#!/usr/bin/env node

'use strict';

const url = require('url');
const path = require('path');
const http = require('http');
const child_process = require('child_process');

const document_root = process.cwd();

var queue = [];
var child;

const run = (script_filename)=> {

    child = child_process.spawn(script_filename);
    child.on('exit', ()=> {
        child = null;
        if (queue.length > 0) {
            run(queue.shift());
        }
    });

};

const server = http.createServer((req, res) => {

    let script_filename = path.join(document_root, url.parse(req.url).pathname); //possible security problem
    if (child) {
        if (queue.indexOf(script_filename) == -1) {
            queue.push(script_filename);
        }
    } else {
        run(script_filename);
    }

    res.writeHead(204);
    res.end();

});

server.listen(80);

run(path.join(document_root, 'generate.sh'));
