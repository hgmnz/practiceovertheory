---
layout: post
title: HTTP POST from java client
date: 2006-08-30 12:55:40 -0400
comments: true
---

When using the HTTP POST method to send data accross a network, Java offers some ready to use classes that implement much of the mechanical work:

URL: to create the URL object needed to create the connection, the simplest constructor would be that of a String representing that URL (such as http://www.example.com/resource)

URLConnection: use the URL object to get a connection to the remote resource. Use this instance to set parameters such as setDoInput, setDoOutput, setUsesCache and others - have a look at the javadocs for more.

Use the URLConnection to set the <b>content type</b>. Not doing so will give you headaches...long ones. Here's an example

<code>conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");</code>

Get a DataOutputStream and start sending to that resource.

Get a BufferedReader and start getting a response.

Not setting the content type turned out to be a major bug. The server side of my application is a Java Servlet, and the symptom was basically that the request.getParameter("key-name") is returned nothing, while the getQueryString() returned everything I sent.

Below is a method that sends data via an HTTP POST, and returns the server's response. Note that the method assumes that the "content" parameter has already been encoded using the static URLEncoder.encode() method.

{% codeblock lang:java %}public static String postData(String target, String content) throws Exception{
  System.out.println("About to post\nURL: "+target+ "content: " + content);
  String response = "";
  URL url = new URL(target);
  URLConnection conn = url.openConnection();
  // Set connection parameters.
  conn.setDoInput (true);
  conn.setDoOutput (true);
  conn.setUseCaches (false);
  // Make server believe we are form data...
  conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
  DataOutputStream out = new DataOutputStream (conn.getOutputStream ());
  // Write out the bytes of the content string to the stream.
  out.writeBytes(content);
  out.flush ();
  out.close ();
  // Read response from the input stream.
  BufferedReader in = new BufferedReader (new InputStreamReader(conn.getInputStream ()));
  String temp;
  while ((temp = in.readLine()) != null){
    response += temp + "\n";
   }
  temp = null;
  in.close ();
  System.out.println("Server response:\n'" + response + "'");
  return response;
}{% endcodeblock %}
