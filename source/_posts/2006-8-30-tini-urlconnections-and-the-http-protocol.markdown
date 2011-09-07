---
layout: post
title: Tini, URLConnections and the HTTP Protocol
date: 2006-08-30 14:38:12 -0400
comments: true
---

The folks at Dalsemi have removed many of the classes which would make a .tini binary unnecessarily big. I guess it's a feature, but upgrading from version 1.16 to 1.17 was painful because of this.

When creating a URLConnection, you may get a MalformedURLException. The javadocs for the URL class explain this happens when the protocol is unknown. Hmmm, HTTP is unknown? This suggests that the classes that can handle HTTP are missing.

To fix this, add the following classes to your .tini:

* <code>com.dalsemi.protocol.http.Connection</code>
* <code>com.dalsemi.protocol.http.HTTPClient</code>
* <code>com.dalsemi.protocol.BasicClient</code>
* <code>com.dalsemi.protocol.HeaderManager</code>
* <code>com.dalsemi.protocol.DefaultFileNameMap</code>
* <code>com.dalsemi.protocol.http.HTTPOutputStream</code>

They can all be found in the <code>modules.jar</code> archive which is distributed with the tini1.17 SDK.
