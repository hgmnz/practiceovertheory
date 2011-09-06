---
layout: post
title: PostgreSQL's group by
date: 2009-09-23 17:30:53 -0400
comments: true
---

Last night I noticed a user on IRC complaint on two different channels (#heroku and #rubyonrails) claiming something along the lines of "PostgreSQL sucks: i have this code {% codeblock lang:ruby %}named_scope :with_questions, 
  :joins => :questions, 
  :group => "categories.id, categories.name, categories.created_at, categories.updated_at"{% endcodeblock %} because of the way postgresql handles group by. It should only be <code>"categories.id"</code>."


The user was surprised that this query works on MySQL. Surely, the user was getting the PostgreSQL message: <code>ERROR: column "categories.name" must appear in the group by clause or be used in an aggregate function</code>. It turns out that this is not a bug, and PostgreSQL does not suck as this user initially thought. Furthermore, I tried a similar query on MS SQL Server, and it rightfully complaints: <code>Column 'categories.name' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.</code>

Let's look at solutions.

#### Alternative Queries
The first thing that's wrong about this query is that what the user really wanted was a distinct list of categories that had questions. This is the requirement. To that end, the query should look something like the following two options.

* Option 1: Drop the <code>join</code> and <code>group by</code>, and just use a condition checking whether a question exists for the category:

{% codeblock lang:ruby %}
Category.all(:conditions =>
        'exists (select 1 from questions where categories.id = questions.category_id)')
{% endcodeblock %}

A variation of this can be achieved with the <code>in</code> operator:

{% codeblock lang:ruby %}
Category.all(:conditions => 
        'clients.id in (select client_id from questions)')
{% endcodeblock %}

* Option 2: Again, drop the <code>group by</code>, and use a <code>distinct</code> instead:

{% codeblock lang:ruby %}
Category.all(:select => 'distinct items.*',
             :joins  => :questions)
{% endcodeblock %}

#### *Why* PostgreSQL doesn't like the original query

The <code>group by</code> clause is used to collect data from multiple records having common values in a select statement, and project the result based on some aggregate function. It really does not make any sense to add a <code>group by</code> to a query that does not have an aggregate such as <code>sum()</code>, <code>avg()</code>, <code>min()</code>, <code>max()</code>, <code>count()</code>. There is an exception, but we'll talk about that later.

As an example, we could retrieve every item along with a count of categories per item:

{% codeblock lang:sql %}
select id, name, count(id)
  from items
  inner join categories
    on items.id = categories.item_id
  group by id, name
{% endcodeblock %}

Note that every non-aggregated column on the <code>select</code> list must appear on the <code>group by</code> list. This is necessary for PostgreSQL to know which item's to <code>count</code> on (or <code>sum</code>, or calculate the <code>max</code> on). Let's walk through a simplified example of what happens if we don't include one of these columns on the <code>group by</code> list.

Suppose the following table

<code>
code | city
------------------
0    | Cambridge
0    | Boston
1    | Foxboro
</code>

What happens if we run the following query:

{% codeblock lang:sql %}
select code, city
  from table
  group by code
{% endcodeblock %}

What would you expect PostgreSQL to return for the row with a code equal to 0? Cambridge or Boston? When PostgreSQL is presented with an ambiguous query such as the above, it will stop and report an error. Some other databases may go on and make their own decision as to what to return. To me, this is a broken spec. Futhermore, the result set may be inconsistent and unpredictable across DBMSes, or even queries on the same DB.

#### Exception to the rule

On previous versions of PostgreSQL (pre 8.2), the query plan for a <code>group by</code> was much more efficient than a <code>select distinct</code>. In some older Rails apps, we wrote things like the following to optimize performance:

{% codeblock lang:ruby %}
Question.find(:all
              :group      => Question.column_names.join(', '),
              :conditions => '...')
{% endcodeblock %}

Instead of the more natural:

{% codeblock lang:ruby %}
Question.find(:all,
              :select     => 'distinct items.*',
              :conditions => '...')
{% endcodeblock %}

This was an optimization that was specific to our environment and helped us avoid the relatively poor query plan and expensive <code>Seq Scan</code> that was slowing our app down.

<object width="560" height="340"><param name="movie" value="http://www.youtube.com/v/XODMtOqmb9U&hl=en&fs=1&"></param><param name="allowFullScreen" value="true"></param><param name="allowscriptaccess" value="always"></param><embed src="http://www.youtube.com/v/XODMtOqmb9U&hl=en&fs=1&" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="560" height="340"></embed></object>

I hope that after reading this you realize that this error is helping you as a user write better SQL. Complaining that the example query doesn't run on PostgreSQL is like complaining that your new [Fender Strat](http://www.fender.com/products//search.php?partno=0110100747) sucks because when you play *Here comes the Sun* the very same way you played it on your [Beatles Rock Band](http://www.thebeatlesrockband.com/) guitar, it doesn't sound the same. <code>/endrant</code>
