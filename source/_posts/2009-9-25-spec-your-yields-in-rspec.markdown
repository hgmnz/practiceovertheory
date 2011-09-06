---
layout: post
title: Spec your yields in RSpec
date: 2009-09-25 20:31:37 -0400
comments: true
---

Message expectations in RSpec's Mocking/Stubing framework provide means for spec'ing the yielded objects of a method. For example, consider the following spec where we expect the <code>here_i_am</code> method to <code>yield self</code>:

{% codeblock lang:ruby %}
describe Triviality do
  describe '#here_i_am' do

    let(:triviality) { Triviality.new }

    it 'yields self' do
      triviality.should_receive(:here_i_am).and_yield(triviality)
      triviality.here_i_am { }
    end

  end
end
{% endcodeblock %}

Nice and easy. First we set the expectation and then we exercise the method so that the expectation is met, passing it a "no op" block - <code>{}</code>.

Here's the method to make it pass.

{% codeblock lang:ruby %}
class Triviality

  def here_i_am
    yield self
  end

end
{% endcodeblock %}

Furthermore, we can test many yielded values by chaining the <code>and_yield</code> method on the expectation. Let's add a spec for a method  that yields many times and see how that would play out:

{% codeblock lang:ruby %}
describe Triviality do
  describe '#one_two_three' do

    let(:triviality) { Triviality.new }

    it 'yields the numbers 1, 2 and 3' do
      triviality.should_receive(:one_two_three).and_yield(1).and_yield(2).and_yield(3)
      triviality.one_two_three { }
    end

  end
end
{% endcodeblock %}

And the method to make that pass:

{% codeblock lang:ruby %}
class Triviality

  def one_two_three
    yield 1
    yield 2
    yield 3
  end

end
{% endcodeblock %}

This is kind of ugly though. What if it yields many more times, or if you just want to test that it yields all items of an array? A good example of this is the Enumerable's <code>each</code> method. In such cases we can store the <code>MessageExpectation</code> object and call <code>and_yield</code> on it many times, in a loop. Take a look at the following example where we yield each letter of the alphabet:

{% codeblock lang:ruby %}
describe Triviality do
  describe '#alphabet' do

    let(:triviality) { Triviality.new }

    it 'yields all letters of the alphabet' do
      expectation = triviality.should_receive(:alphabet)
      ('A'...'Z').each { |letter| expectation.and_yield(letter) }
      triviality.alphabet { }
    end

  end
end
{% endcodeblock %}

And finally, the method to make it pass:

{% codeblock lang:ruby %}
class Triviality

  def alphabet
    ('A'...'Z').each do { |letter| yield letter }
  end

end
{% endcodeblock %}

<code>and_yield</code> is not only useful for message expectations. You can also use it on your <code>stubs</code>, just like you'd use <code>and_returns</code>. 
