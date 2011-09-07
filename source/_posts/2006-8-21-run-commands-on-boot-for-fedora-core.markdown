---
layout: post
title: Run commands on boot for Fedora Core
date: 2006-08-21 08:36:00 -0400
comments: true
---

To easily run commands on boot, without going through the Sys V init scripts, add them to the following file:

<code>/etc/rc.d/rc.local</code>

Commands in this file will execute after all the other init scripts.

On the other hand, here is how to start services on boot using Sys V init scripts. If we want to start the apache web server for run-levels 3 and 5:

<code>/sbin/chkconfig --level 35 httpd on</code> 
