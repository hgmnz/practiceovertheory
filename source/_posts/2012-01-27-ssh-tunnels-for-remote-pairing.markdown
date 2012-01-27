---
layout: post
title: "SSH Tunnels for Remote Pairing"
date: 2012-01-27 08:51
comments: true
categories:
---

Yesterday was a good day. [@pvh](http://twitter.com/pvh) and I paired for a few
hours, even though we're at opposite coasts.

Here's what you need:

* A server somewhere that both pairs have access to. We used an EC2 instance.
  We'll use it to meet up and create the tunnel.
* SSH client libs - your should already have this unless you're on windows in
  which case you probably want PuTTY.
* Skype for audio.

As you know, The Internet is made of nodes connected by Tubes. Unfortunately,
there is no tube from your machine to your pair's machine. What we'll do here is
use a third node that has tubes to both of your machines to relay traffic
through, in essence creating an Internet Tube from your machine to your pair's.
This kind of Internet Tube is called a Tunnel. Since we're using SSH to do the
traffic encryption and forwarding, it's an SSH Tunnel. Yes, that's somewhat made
up, but sounds legit!

<img src="http://doctorwatson.info/images/lolcats/1111%20internet%20tube%20cat.jpg" />

As it turns out, setting up a tunnel is fairly simple. For example, let's set
up a tunnel between you and Jane using a remote server saturn.

1. You: Open up a shell and forward traffic to your local port 9999 over to
   Saturn's port 1235:

```
ssh -L 9999:locahost:1235 saturn_user@saturn
```

2. Jane: Open up a shell and forward traffic from saturn's port 1235 to her port
   22

```
ssh -R 1235:localhost:22 saturn_user@saturn
```

3. You: Open up another shell, and ssh into your local port 9999 specifying a
   username on Jane's machine.
```
ssh jane_user@jane -p 9999
```

And you're good to go. Create a shared screen session, open up $EDITOR, use
skype, google hangouts, face time or whatever for audio and start ping ponging.

The latency was surprisingly minimal. We left this tunnel open most of the day.
It sat idle for periods of time and the connection was left active. All in all,
a great setup.

If this is something you'll do often, you might as well add a more permanent
configuration to <code>~/.ssh/config</code>. For example, you might add:

{% codeblock ~/.ssh/config on your machine %}
Host tunnel_to_jane
  Hostname saturn
  LocalForward 9999:localhost:1235
  User saturn_user

Host jane
  Hostname jane
  User jane_user
  Port 9999
{% endcodeblock %}

Then you'd do, on one terminal, <code>ssh tunnel_to_jane</code>, and on the
other <code>ssh jane</code>.

And Jane might add:

{% codeblock ~/.ssh/config on Jane's machine %}
Host tunnel_from_you
  Hostname saturn
  RemoteForward 1235:localhost:22
  User saturn_user
{% endcodeblock %}

And she'd just do, <code>ssh tunnel_from_you</code>

This can be used not ony for remote pairing, but rather to forward <em>any</em>
traffic on a port, over an SSH encrypted channel, to a remote host. For more
see <code>ssh_config(5)</code> and <code>ssh(1)</code>, and happy pairing!
