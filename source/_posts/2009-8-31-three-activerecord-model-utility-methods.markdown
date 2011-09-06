---
layout: post
title: Three ActiveRecord model utility methods
date: 2009-08-31 20:40:34 -0400
comments: true
---

Lately I've found myself implementing at least two out of three of these utility methods on most of my ActiveRecord models on my Rails apps. These methods leverage functionality of either Ruby by itself or Rails that will become helpful in other parts of your application.

<a href="http://www.flickr.com/photos/adams_views/3096986188/"><img src="http://farm4.static.flickr.com/3057/3096986188_0599337f47.jpg" title="Visit original on Flickr"></a>
### The labeler: #to_s

  Defining a to_s method enables a very clean way to display a label that represents your model instance. Suppose you have a Post model. You could define a #to_s method similar to the following:

{% codeblock lang:ruby %}
def to_s
  title
end
{% endcodeblock %}

Now your views can simply do something like the following HAML:
{% codeblock lang:haml %}
.post
  .h2= @post
{% endcodeblock %}

### The quantifier: #<=>

This method is useful when you consistently need to be able to respond to the question "Which of these is bigger/better/taller/fatter/purtier?". Which metric defines the quantity is completely up to you, but what's important is that defining this method will allow you to call the <code>Enumerable</code> goodies <code>#min</code>, <code>#max</code>, and <code>#sort</code>. For example, and following the Post model example above, you could imagine the following method definition.

{% codeblock lang:ruby %}
def <=>(other)
  rating <=> other.rating
end
{% endcodeblock %}

Assuming you have a <code>recent</code> named_scope that returns the latest <code>n</code> posts, you could do things like <code>Post.recent.max</code> or <code>Post.recent.sort</code>.

### The SEOer: #to_param

Finally, this method is leveraged by Rails itself. You can take advantage of the fact that the :id parameter on Rails URLs can be any sequence of integers followed by any non-whitespace characters. Rails will ignore any character after the integers, and use that as the :id parameter. It is customary to use the post's title as part of the URL. An easy way to achieve this in Rails is to define the following method on your model:

{% codeblock lang:ruby %}
def to_param
  "#{id}-#{title.parameterize}"
end
{% endcodeblock %}

Rails will call to to_param method when using <code>post_url(@post)</code>, and your URLs shal become *slugs*, in SEO terms.
