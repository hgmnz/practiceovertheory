---
layout: post
title: Really silly percentage calculation in Ruby
date: 2009-03-22 15:56:07 -0400
comments: true
---

Here's a silly way to calculate percentages of numbers in a Ruby project or Rails app.

The end result of this is having created a few methods for Ruby numeric classes that allow you to calculate percentages:
{% codeblock lang:ruby %}>> 23.456.five_percent
=> 1.1728
>> 100.46.seven_percent
=> 7.0322
>> 95.fifty_percent
=> 47.5{% endcodeblock %}

To accomplish this, we'll use use meta programming to add the methods to the Fixnum and Float classes.

First, create a way to translate numbers in English to numeric values. This was taken from a thread at [ruby-forum](http://www.ruby-forum.com/topic/132735#591799).

Then, we'll make use of Ruby's <code>method_missing</code> to find out if this is a <code>*_percent</code> method and act accordingly. The <code>percent_method?</code> method returns <code>true</code> if it is, <code>false</code> if it ain't.

{% codeblock lang:ruby %}module NumberPercentageExtension
  module InstanceMethods
    ENGLISH_VALUE = {}
      %w| zero one two three four five six seven eight nine ten eleven
          twelve thirteen fourteen fifteen sixteen seventeen eighteen
          nineteen |.each_with_index{ |word,i| ENGLISH_VALUE[word] = i }
      %w| zero ten twenty thirty forty fifty sixty seventy eighty
          ninety|.each_with_index{ |word,i| ENGLISH_VALUE[word] = i*10 }
    ENGLISH_VALUE['hundred'] = 100
    def percent_method?(method)
      tokens = method.to_s.split('_')
      return false if tokens.size < 2
      is_percent = tokens[-1] == 'percent'
      tokens[0..-2].collect { |word| is_percent &&= ENGLISH_VALUE.has_key?(word) }
      return is_percent
    end
    def method_missing(method, *args)
      if percent_method?(method)
        method.to_s.split('_')[0..-2].map { |word| ENGLISH_VALUE[word] }.sum * self / 100.to_f
      else
        super
      end
    end
  end
end{% endcodeblock %}

 We also want <code>respond_to?</code> to be aware of the new *_percent methods, so we include that as well.

{% codeblock lang:ruby %}    
def respond_to?(method)
  return true if percent_method?(method)
  super(method)
end{% endcodeblock %}

 Finally, include the module in <code>Numeric</code>:
{% codeblock lang:ruby %} 
Numeric.class_eval do
  include InstanceMethods
end
{% endcodeblock %}

The full code listing can be found in [this gist](http://gist.github.com/83258).
