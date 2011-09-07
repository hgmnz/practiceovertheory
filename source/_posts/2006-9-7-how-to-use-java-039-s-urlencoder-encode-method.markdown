---
layout: post
title: How to use Java&#039;s URLEncoder.encode() method
date: 2006-09-07 23:15:39 -0400
comments: true
---

For the lazy readers, here's how to use it:
{% codeblock lang:java %}String encodedString = URLEncoder.encode("the key", "UTF-8") + "=" + URLEncoder.encode("the value with any type of character such as @, ñ, or even ç!", "UTF-8");
{% endcodeblock %}

When <a href="http://labnotesh.wordpress.com/2006/08/30/http-post-from-java-client/">POSTing to a URL</a>, it is necessary to encode the parameters you are sending. Not doing so correctly will likely introduce bugs in the communication as the server will not know how to deal with (decode) the recieved data.

Lookin at the [javadocs for URLEncoder](http://java.sun.com/j2se/1.4.2/docs/api/java/net/URLEncoder.html), we find that <em>normal</em> alpha-numeric characters remain the same after encoding them to UTF-8, but other characters, such as the equal sign, change.

The server expects something like <code>key1=value1&amp;key2=value2</code>. The <code>=</code> and <code>&amp;</code> signs must be sent <strong>as is</strong>, without encoding. The <code>URLEncoder.encode</code> method is not "smart" enough to know that <code>=</code> and <code>&amp;</code> are to be used as part of the URL. Of course, it isn't fair to assume that...
