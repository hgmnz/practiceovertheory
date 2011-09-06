---
layout: post
title: An object quacks like a duck
date: 2009-09-24 21:58:19 -0400
comments: true
---

I've been toying around with the idea of spec'ing mixins: that a class includes a module. Suppose the following class:

{% codeblock lang:ruby %}
class FooList
  include Enumerable
 
  attr_accessor :some_array
  def initialize(opts)
    @some_array = opts[:the_array] || []
  end
 
  def each
    @some_array.each { |item| yield item }
  end
end
{% endcodeblock %}

We can test the behavior of the <code>each</code> method using RSpec, but we can also make sure that <code>FooList</code> actually acts like an <code>Enumerable</code>. Here's a quick RSpec Matcher just for that (<code>require</code> it in your spec_helper.rb)

{% codeblock lang:ruby %}
Spec::Matchers.define :quack_like do |mod|
  match do |instance|
    mod.instance_methods.inject(true) { |accum, method| accum && instance.respond_to?(method) }
  end

  failure_message_for_should do |instance|
    "expected the class #{instance.class.name} to include the module #{mod}"
  end

  failure_message_for_should_not do |instance|
    "expected the class #{instance.class.name} not to include the module #{mod}"
  end

  description do
    "expected the class to behave like a module by responding to all of its instance methods"
  end
end{% endcodeblock %}

This allows us to spec some quacking:

{% codeblock lang:ruby %}
describe FooList do
  def foo_list
    @foo_list ||= FooList.new
  end

  it "quacks like an Enumerable" do
    foo_list.should quack_like Enumerable
  end
end
{% endcodeblock %}

I am still experimenting with this. In a way it is not really testing behavior, but it's not really testing the implementation either. In other words, if every method in <code>Enumerable</code> is implemented in <code>FooList</code> and we remove the <code>include Enumerable</code> line, the spec still passes.

I've discussed this over IRC with some other [smart](http://technicalpickles.com/) [folks](http://www.enlightsolutions.com/), but I want more input . Do you think this is appropriate? Useless?
