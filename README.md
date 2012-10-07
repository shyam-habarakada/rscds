rscds
=====

A really simple continuous deployment (continuous integration) server. 

How to use RSCDS
----------------

1. Install nodeJS on your linux server
2. Copy and modify this script to match your site configuration and domain(s)
3. Add a post recieve hook to your github repo and point it to your node server URL. The webhook URL must be like

    http://www.yourdomain.com:8088/update?site=wwwstage&secret_key=YOUR_SECRET_KEY
    
where, wwwstage is a site defined in your siteMap.

4. Start the node server

Ideally, you want to configure the node server to un as a daemon.
