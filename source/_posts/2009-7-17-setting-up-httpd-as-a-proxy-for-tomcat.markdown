---
layout: post
title: Setting up httpd as a proxy for Tomcat
date: 2006-09-05 16:57:18 -0400
comments: true
---

After installing Tomcat, the default port for the http requests it listens to is 8080.

If your server is also running Apache's httpd along with Tomcat, this solution makes them happily work together. It takes two steps:

1. In httpd's configuration file (httpd.conf - located in /etc/httpd/conf/httpd.conf on a Fedora Core installation), add the following lines (let's assume your hostname is example.com).
<code>ProxyPass               /       http://example.com:8080/
ProxyPassReverse        /       http://example.com:8080/</code>

These lines say "redirect all trafic from / (on the httpd server) to http://example.com:8080/ (on Tomcat)".

2. Change the following lines to look like these (doing a search for mod_proxy will take you there).
<code><IfModule mod_proxy.c>
ProxyRequests Off
<Proxy *>
  Order allow,deny
  Allow from all
</Proxy></code>

I did this a while ago, so if this doesn't work for you please let me know ;)

Another way of integrating tomcat and httpd is by using httpd's mod_jk. You can easily <a href="http://www.google.com/search?q=tomcat%20httpd%20mod_jk">google it.</a>
