---
layout: post
title: Experiences porting a helper plugin to Rails 3
date: 2010-01-17 19:55:45 -0500
comments: true
---

Today I spent a few minutes porting [truncate_html](http://github.com/hgimenez/truncate_html) to Rails 3. This gem/plugin provides you with the `truncate_html()` helper method, which is very similar to rails' `truncate()`, but it takes care of closing open html tags and other peculiarities of truncating HTML. It works by using regular expressions and does not have any dependencies. I use this gem on this blog, as well as on the [bostonrb.org](http://bostonrb.org) site. Some other people have found it to be [useful](http://twitter.com/dolzenko/status/6428360551).

One of the promises of Rails 3 is that there is an [API for plugin developers](http://www.engineyard.com/blog/2010/rails-and-merb-merge-plugin-api-part-3-of-6/) that will allow you to hook into the right parts of Rails to add the functionality that your plugin provides. This means that you should not be mixing in or monkeypatching Rails core willy-nilly. In fact, it is now expected for you as a plugin developer to figure out how to hook into the right parts of Rails using the new API, as opposed to doing something like the following:

{% codeblock lang:ruby %}
ActionView::Base.class_eval do
  include TruncateHtmlHelper
end
{% endcodeblock %}

At this stage, there isn't much documentation around what the API actually is. But this shouldn't stop you from investigating and finding out. In this case, cloning the rails repo and using ack pointed me towards [actionpack/lib/action_controller/metal/helpers.rb](http://github.com/rails/rails/blob/master/actionpack/lib/action_controller/metal/helpers.rb#L6-39), where I found all the info I needed to remove the now outdated meta-programmed mixin technique of the dark Rails 2 days. From the docs:

<blockquote><pre>
In addition to using the standard template helpers provided in the Rails framework,
creating custom helpers to extract complicated logic or reusable functionality is strongly
encouraged. By default, the controller will include a helper whose name matches that of
the controller, e.g., MyController will automatically include MyHelper.

Additional helpers can be specified using the helper class method in
ActionController::Base or any controller which inherits from it.
</pre></blockquote>

Perfect. All I need to do in this case is [call the `helper` class method with my helper's module](http://github.com/hgimenez/truncate_html/commit/5a33e52db3297a1b35af224d468636e2e68ecdc4): <code>ActionController::Base.helper(TruncateHtmlHelper)</code>. A quick run through the app demonstrates however that we now need to mark strings as html_safe. Fine, let's [do that](http://github.com/hgimenez/truncate_html/commit/7539b71f3c572f81ed890d2a9e9156ff51408e2b): <code> (TruncateHtml::HtmlTruncator.new(html).truncate(options)).html_safe!</code>

Finally, let's run the test suite - and *facepalm*. The way this plugin is set up is that RSpec must be installed in the containing app for it to run the spec suite. Here's where I ran into the first real issue with the upgrade: I have not been able to install RSpec on a Rails 3 app. I also can't find any obvious way to do it by browsing its source code. For now I seem to be stuck in limbo land until the [the RSpec/Rails 3 affair](http://blog.davidchelimsky.net/2010/01/12/rspec-2-and-rails-3/) is all sorted out.

### Backward Compatibility

The bigger question is how to maintain backward compatibility. One way to accomplish this is to continue to maintain two git branches for Rails2 and Rails3 (master), and cherry-picking any bug fixes or enhancements from the master branch into the Rails2 branch. However, how could we manage gem bundling and distribution of two gems built for two version of Rails? I'd like to know how you are planning on maintaining backward compatibility. In this particular case, I almost don't care for backward compatibility, and users will simply have to know that version 0.2.2 of the gem is the latest working Rails 2 version, and must install that specific version when running under Rails 2.
