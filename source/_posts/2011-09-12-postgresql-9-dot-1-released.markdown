---
layout: post
title: "PostgreSQL 9.1 Released"
date: 2011-09-12 09:18
comments: true
---

Version 9.1 of PostgreSQL was [released](http://www.postgresql.org/about/news.1349) yesterday.

Among the exiting new features there is:

* `pg_basebackup` - this can be used alongside Streaming Replication to perform a backup or clone of your database. I can imagine [heroku](http://heroku.com) adopting this as an even faster and reliable way to sync you're production and staging databases, for example (when and if they upgrade to 9.1). However it can also be used to create plain old tarballs and create standalone backups.

* Another replication goodie: Synchronous replication. On Postgres 9.0, replication was asynchronous. By enabling synchronous replication, you are basically telling the master database to only report the transaction as committed when the slave(s) have successfully written it to its own journal. You can also control this on a specific session by doing `SET synchronous_commit TO off`.

* The new `pg_stat_replication` view displays the replication status of all slaves from a master node.

* Unlogged tables. What? Postgres supports unlogged tables now? Yes, it does. They can be used for data you don't necessarily care about, and a crash will truncate all data. They are much faster to write to and could be useful for caching data or keeping stats that can be rebuilt. You can create them like so:

{% codeblock lang:sql %}
CREATE TABLE UNLOGGED some_stats(value int)
{% endcodeblock %}

* SQL/MED gets the ability to define foreign tables. This is rich. It means that you can define a foreign data wrapper for a different database and access it from Postgres seamlessly. Some hackers have already built [some nifty foreign data wrappers]( http://wiki.postgresql.org/wiki/Foreign_data_wrappers) for mysql, oracle, and even redis and couchdb. Although I'm of the mind that if you're actually using any of these databases to supplement your app's data needs, just talk to them directly from your app. However, it may be possible to write some higher performance reports that use different data sources, and you let Postgres do the heavy lifting of munging all the data together.

* You no longer need to specify all columns on a select list from your GROUP BY clause: functionaly dependant columns are infered by the planner, so specifying a primary key is sufficient. I [talked about this before](http://practiceovertheory.com/blog/2009/09/23/postgresql-s-group-by/), and it's a cause of great frustration to users coming from MySQL.

There's much more in this release. Here are the [release notes](http://www.postgresql.org/docs/9.1/static/release-9-1.html).

Huge thanks, Postgres hackers!
