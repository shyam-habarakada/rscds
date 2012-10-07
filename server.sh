#!/usr/local/bin/node

var http = require('http'),
    url = require('url'),
    exec = require('child_process').exec;

var host = "dev.artefactgroup.com",
    port = "8088",
    thisServerUrl = "http://" + host + ":" + port;

/* The sites that are being continuously integrated.
 * Add new site definition here and specify the updateCmd to be run when a post recieve hook is invoked
 */
var siteMap = {
    wwwstage : { updateCmd : "cd /var/www-benchpress-mkt-site-stage; git pull origin master; mail you@yourdomain.com - s 'wwwStage updated at `date`'" }
  }

http.createServer(function (req, res) {

  var parsedUrl = url.parse(req.url, true);
  var siteId = parsedUrl.query['site'];
 
  switch(parsedUrl.pathname) {
    case '/':
      res.writeHead(501, "Not implemented", {'Content-Type': 'text/html'});
      res.end('501 - Not implemented');
      break;

    case '/update':
      console.log("[processing] " + req.url);
      var site = parsedUrl.query['site'];
      if(siteMap[site]) {
        exec(siteMap[site].updateCmd, function (error, stdout, stderr) {
          res.writeHead(200, "OK", {'Content-Type': 'text/html'});
          res.end("OK");
        });
      } else {
        console.log("[error] unknown site " + site);
        res.writeHead(410, "Gone", {'Content-Type': 'text/html'});
        res.end("410 - Gone");
      }
      break;

    default:
      res.writeHead(404, "Not found", {'Content-Type': 'text/html'});
      res.end("404 - Not found");
      console.log("[404] " + req.method + " to " + req.url);
  };

}).listen(port, host);
console.log('Server running at ' + thisServerUrl );