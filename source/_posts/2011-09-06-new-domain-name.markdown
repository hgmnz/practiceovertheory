---
layout: post
title: "New domain name, new blog engine"
date: 2011-09-06 21:58
comments: true
---

I haven't touched my blog for a while. Part of it is that I just didn't identify myself with "Awesomeful" any more. On the other hand, have I got a deal for you! Both awesomeful.net and awesomeful.org are for sale, so [hit me up](http://twitter.com/hgimenez) if you're interested - I'm talking to you mister `whois awesomeful.com`.

Welcome to the new blog: *Practice Over Theory*. I hope that the new name and engine inspire me to post more often.

Migrating was not a huge task at all. I decided to give octopress a try. It prescribes a [really weird method](http://octopress.org/docs/deploying/) of deploying to github pages which involves cloning yourself into a subdirectory (!!), but now I have a pretty neat set up. It's backed by jekyll and has a few nice addons, the most useful of which is it's code highlighting theme which is based on Solarized.

Speaking of code highlighting, let me show you a little rack app that redirects the old awesomeful.net posts to their new warm locations:

{% codeblock lang:ruby %}
require 'rubygems'
require 'sinatra'

REDIRECTS = {
              'awesomeful-post-1' => 'new-location-1',
              'awesomeful-post-2' => 'new-location-2'
            }

get '/*' do |path|
  one_year_in_seconds = 31536000
  headers 'Cache-Control' => "public, max-age=#{one_year_in_seconds}",
          'Expires'       => (Time.now + one_year_in_seconds).httpdate

  redirect to("http://practiceovertheory.com/#{REDIRECTS[path]}"), 301
end

{% endcodeblock %}

Pretty neat, huh? The syntax highlighting, I mean.

Regarding the above sinatra app, I just have a dictionary[1] mapping the old paths to the new ones, and respond with a `HTTP 301 Moved Permanently`. The interesting bit is the HTTP caching employed. Heroku's (awesome) varnish servers will remember that response for one year. Try it [here](http://awesomeful.net/posts/45-postgresql-rails-and-why-you-should-care).

[1] it's a hash!
