---
layout: post
title: Client Side API Mashups With CORS
date: 2012-10-27 10:17
comments: true
categories:
---

At Heroku we have APIs for pretty much everything. Need logs for an app? Is
that database available? You just beat someone at ping pong? There's an API for
that. Having such rich datasets available is great. It allows us to build
dashboards with mashups of different datasets and serve them from a web
browser.

Here are some of the techniques implemented in order to wire up a Backbone.js
application speaking to remote hosts in a secure manner. We will explore
Cross-Origin Resource Sharing (CORS) as well as HMAC based auth tokens with
cryptographically timestamped data that an attacker wouldn't be able to
auto-replay. The end goal is to have an application running on a browser, and
securely request data from an API running on a remote host.

The first problem when issuing XHR requests across hosts will be the
same-origin policy violation. Go ahead, issue an AJAX request against a remote
host. The browser should fail with an error similar to the following:

```
XMLHttpRequest cannot load https://some.remote.com. Origin https://your.site.com is not allowed by Access-Control-Allow-Origin
```

This is where [Cross Origin Resource Sharing (CORS)](http://en.wikipedia.org/wiki/Cross-origin_resource_sharing)
 comes in.  The way it works is that the Origin (the client) will issue what's
called a pre-flight request, asking the server "hey, can I make a request with
HTTP verb foo to path /bar with headers x-baz?", to which the server responds,
"Sure, bring it!", or "No, you may not". This pre-flight request is made to the
same path as the actual request, but the HTTP `OPTIONS` verb is used instead.
The server responds with the following headers, should the request be allowed:

* `Access-Control-Allow-Origin`: Specifies what Origins are allowed remote XHR
 requests to be made against this server. Allowed values include a URL (eg:
 https://your.site.com), a comma separated list of URLs, or an asterisk
 indicating all origins are allowed.
* `Access-Control-Allow-Headers`: Specifies a comma separated list of headers
 that the Origin is allowed to include in requests to this server. There are
 many reasons to include custom headers - we'll see an example of this further
 down.
* `Access-Control-Max-Age`: This is optional, but it allows the browser to
 cache this response for the given number of seconds, so browsers will save
 themselves the pre-flight request any subsequent times. Freely set it to a
 large number, like 30 days (2592000)

There are more headers that allow you to whitelist and otherwise control access to the resource. Be sure to [read up](https://developer.mozilla.org/en/HTTP_access_control) on CORS.

Thus, a Sinatra app acting as the remote end of the system can respond to pre-flight OPTIONS requests like so:

{% codeblock lang:ruby %}
options '*' do
  headers 'Access-Control-Allow-Origin'  => 'https://your.site.com',
          'Access-Control-Allow-Headers' => 'x-your-header',
          'Access-Control-Max-Age'       => '2592000'
end
{% endcodeblock %}

Inclusion of the Allow Origin and Allow Headers headers is also necessary on responses to any other remote XHR requests. We can extract the headers directive to a helper and use it on both pre-flight and other requests:

{% codeblock lang:ruby %}
options '*' do
  cors_headers
  headers 'Access-Control-Max-Age' => '2592000'
end

post '/resources' do
  cors_headers
  # do_work
end

private
def cors_headers
  headers 'Access-Control-Allow-Origin'  => 'https://your.site.com',
          'Access-Control-Allow-Headers' => 'x-your-header'
end
{% endcodeblock %}

And just like that, browsers can now issue XHR requests against remote APIs. Of
course, there is no authentication in place yet.

We will implement an HMAC based auth token mechanism. Both the remote server
and your app share a secret. This secret is used to generate a token containing
a timestamp that is used for validating token recency.

To generate the token, we create a JSON document containing an `issued_at`
timestamp, and we calculate its sha256 HMAC token using the secret known to
both parties. Finally, we append this signature to the JSON document and we
base64 encode it to make it safe to send over the wire. Here's an example
implementation:

{% codeblock lang:ruby %}
require 'openssl'
require 'json'
require 'base64'
def auth_token
  data      = { issued_at: Time.now }
  secret    = ENV['AUTH_SECRET']
  signature = OpenSSL::HMAC.hexdigest('sha256', JSON.dump(data), secret)
  Base64.urlsafe_encode64(JSON.dump(data.merge(signature: signature)))
end
{% endcodeblock %}

This token is used on the API server to authenticate requests. The client can
be made to send a custom header, let's call it X_APP_AUTH_TOKEN, which it must
be able to reconstruct the token from the JSON data, and then validate that the
request is recent enough. For example in a Sinatra application:

{% codeblock lang:ruby %}
def not_authorized!
  throw(:halt, [401, "Not authorized\n"])
end

def authenticate!
  token           = request.env["HTTP_X_APP_AUTH_TOKEN"] or not_authorized!
  token_data      = JSON.parse(Base64.decode64(token))
  received_sig    = token_data.delete('signature')
  regenerated_mac = OpenSSL::HMAC.hexdigest('sha256', JSON.dump(token_data), ENV['AUTH_SECRET'])

  if regenerated_mac != received_sig || Time.parse(token_data['issued_at']) > Time.now - 2*60
    not_authorized!
  end
end
{% endcodeblock %}

{% pullquote %}
In the above code, we consider a token invalid if it was issued more than 2
minutes ago. Real applications will probably include more data in the auth
token, such as the email address or some user identifier that can be used for
auditing and whitelisting.  *All of the above data token generation and
verification has been extracted to a handy little gem called 
[fernet](http://github.com/hgmnz/fernet)*.
{" Do not reimplement this, just use fernet. "}
{% endpullquote %}


The `authenticate!` method must be invoked before serving any request. This
means that the auth token must be included on every request the client makes.
There are many ways of doing this. One approach, if you're using JQuery to back
Backbone.sync(), is to use its $.ajax beforeSend hook to include the header, as
can be seen in the following coffeescript two-liner:

{% codeblock lang:javascript %}
$.ajaxSetup beforeSend: (jqXHR, settings) ->
  jqXHR.setRequestHeader "x-app-auth-token", YourApp.authToken
{% endcodeblock %}

YourApp.authToken can come from a number of places. I decided to bootstrap it
when the page is originally served, something like:

{% codeblock lang:javascript %}
<script type="text/javascript">
  YourApp.authToken = "<%= auth_token %>";
</script>
{% endcodeblock %}

In addition to that, it should be updated in an interval, so that on a single
page app, that doesn't request any page refreshes, the auth token is always
fresh and subsequent API requests can be made.

The final client side code that provides the auth token and keeps it updated
looks like so:

{% codeblock lang:javascript %}
<script type="text/javascript">
  App.authToken       = "<%= auth_token %>; //bootstrap an initial value
  App.refresh_auth_token = function() {
    $.getJSON('/auth_token', function(data) {
      App.authToken = data.token; //request updated values
    })
  };
  window.setInterval(App.refresh_auth_token, 29000); //every 29 seconds
</script>
{% endcodeblock %}

The fernet token expires every minute by default. I decided to update it
every 29 seconds instead so that it can be updated at least twice
before it has a chance to hold and use an expired token against a remote API.

In this app, the server side is used for one thing only: user authentication.
The way it works is that when a request is made, the sinatra app performs oauth
authentication against our google apps domain. Once the oauth dance has
suceeded, the app generates a token that is handed on to the client for
authenticating against backend, remote APIs.

This whole setup has worked great for some months now.

