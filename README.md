rscds
=====

A really simple continuous deployment (continuous integration) server. 

How to use RSCDS
----------------

1. Install nodeJS on your linux server
2. Copy and modify this script to match your site configuration and domain(s)
   2.1 Specifically, edit the site_key to match the site_key you've specified in the github post recieve hook url, and
   2.2 edit the siteMap in the node server script to map to that site key and repo branches that you want to setup for continuous deployment.
3. Add a post recieve hook to your github repo and point it to your node server URL. The webhook URL must be like

    http://www.yourdomain.com:8088/update?site=wwws&secret_key=YOUR_SECRET_KEY
    
where, wwwstage is a site defined in your siteMap.

4. Start the node server

Ideally, you want to configure the node server to un as a daemon.
