#!/usr/local/bin/node
 
var http = require('http'),
    url = require('url'),
    exec = require('child_process').exec,
    qs = require('querystring');
 
var host = "your.domainname.com",
    port = "8088",
    thisServerUrl = "http://" + host + ":" + port,
    secret_key = "YOUR_SECRET_KEY";

/* These keys map to a specific site id configured on the querystring of the 
 * github post recieve hook URL you provided and the ref id corresponding to your
 * githum repo. We concatanate the two and replace / with _ to form unique keys that
 * identify the site and a git branch.
 */
var siteMap = {
    www_refs_heads_master :  { updateCmd : "cd /var/www-stage; git pull origin master;  echo `date` | mail you@yourdomain.com -s 'www stage updated'" },
    www_refs_heads_release : { updateCmd : "cd /var/www; git pull origin release;       echo `date` | mail you@yourdomain.com -s 'www updated'" }
  }

process.on('uncaughtException', function (err) {
  console.log('[exception] ' + err);
});

http.createServer(function (req, res) {
  var data = "";

  req.on("data", function(chunk) {
    data += chunk;
  });

  req.on("end", function() {
    var parsedUrl = url.parse(req.url, true);
    var siteId = parsedUrl.query['site'];
    var params = {};

    if(parsedUrl.query['secret_key'] != secret_key) {
      console.log("[warning] Unauthorized request " + req.url);
      res.writeHead(401, "Not Authorized", {'Content-Type': 'text/html'});
      res.end('401 - Not Authorized');
      return;
    }

    if(data.length > 0) {

      /* todo This code can be a lot more robust, with checks for request content type
       * and other error handling. I'm skipping that for now because I know exactly what 
       * github sends in it's post recieve hooks. 
       *
       * For more details see, https://help.github.com/articles/post-receive-hooks
       */

      // debugging
      // console.log("[trace] data is '" + data + "'");

      params = JSON.parse(qs.parse(data).payload); 
      console.log("[ref] " + params.ref);
    }

    switch(parsedUrl.pathname) {
      case '/':
        res.writeHead(501, "Not implemented", {'Content-Type': 'text/html'});
        res.end('501 - Not implemented');
        break;

      case '/update':
        var site = parsedUrl.query['site'];
        if(params.ref) { site = site + "_" + params.ref.replace(/\//g,"_") };
        console.log("[processing] " + req.url + " for site " + site);
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

  });

}).listen(port, host);

console.log('Server running at ' + thisServerUrl );