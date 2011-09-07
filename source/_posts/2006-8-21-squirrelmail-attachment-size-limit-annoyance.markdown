---
layout: post
title: Squirrelmail Attachment size limit annoyance
date: 2006-08-21 12:58:00 -0400
comments: true
---

If you get the message "Documents contains no data" (message depends on browser) in a Squirrelmail deployment, it is probably Apache's configuration.

To fix this, comment out the line containing <code>LimitRequestBody</code> in <code>/etc/httpd/conf.d/php.conf</code> and it should work after restarting httpd.

Also, check for <code>memory_limit</code>, <code>post_max_size</code>, and <code>upload_max_filesize</code> in <code>/etc/php.ini</code> 
