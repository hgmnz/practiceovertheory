---
layout: post
title: PostgreSQL, Rails, and why you should care
date: 2009-08-03 12:59:46 -0400
comments: true
---

MySQL is the most popular RDBMS used to back Ruby on Rails applications. However, there are many reasons to try out PostgreSQL. It offers performance, efficiency, feature set, configurability, and seamless integration in your Rails projects.

### PostgreSQL Features

PostgreSQL supports all of the features you would expect from an open source RDMS, including many that are found in commercial databases (Oracle, DB2, SQL Server) such as:

* The basics: [views](http://www.postgresql.org/docs/8.4/static/sql-createview.html), [triggers](http://www.postgresql.org/docs/8.4/static/triggers.html), [indexes](http://www.postgresql.org/docs/8.4/static/indexes.html), [foreign keys](http://www.postgresql.org/docs/8.4/static/ddl-constraints.html#DDL-CONSTRAINTS-FK), ACIDity, [transactions](http://www.postgresql.org/docs/8.4/static/transaction-iso.html), [query optimization](http://www.postgresql.org/docs/8.4/static/geqo-pg-intro.html), comprehensive SQL support and [data types](http://www.postgresql.org/docs/8.4/static/datatype.html), [autovacuum](http://www.postgresql.org/docs/current/static/routine-vacuuming.html) (keeps your table statistics up to date).
* The not so basics: Features that may not be seen on other DBMSes include reverse, partial and expression indexes, table partitioning, table inheritance, cursors, data domains, user-defined operators, arrays and regular expressions.
* [Procedural Languages](http://www.postgresql.org/docs/8.4/static/xplang.html): analogous to Oracle's PL/SQL or SQL Server's T/SQL, PostgreSQL supports internal procedural languages for when you need to get down and dirty with the data. Additionally, it supports a wide range of languages [including *Ruby*](http://raa.ruby-lang.org/project/pl-ruby/).
* [Rules](http://www.postgresql.org/docs/8.4/static/rules.html), which pretty much allow you to rewrite an incoming query. A typical use of Rules is to implement updatable views.
* [Multi-Version Concurrency Control](http://www.postgresql.org/docs/current/static/mvcc-intro.html): MVCC is how PostgreSQL (and other DBMSes) deal with concurrency and table locking. In practical terms, it allows for database reads while the data is being writen.
* [Write-Ahead-Log](http://www.postgresql.org/docs/8.4/static/wal-intro.html): the WAL is the mechanism by which PostgreSQL writes transactions to the log before they are written to the database. This increases reliability in the unlikely event of a database crash, as there will be a transaction log by which to rebuild the database's state. PostgreSQL includes many configuration parameters to [tweak the behavior of the WAL](http://www.postgresql.org/docs/8.4/static/wal-configuration.html).
* PostgreSQL scales up by efficiently using multi-core servers. It also sport an [asynchronous processing API](http://www.postgresql.org/docs/8.3/static/libpq-async.html). Subselects are fast, you can refer to tmp tables more than once in a query and it can use more than one index per query, making it suitable for data warehousing applications as well.
* [tsearch2](http://www.postgresql.org/docs/8.4/static/tsearch2.html), which is PostgreSQL's highly efficient full text search component. If you are committed to PostgreSQL, this is a very high performant search engine for PostgreSQL (as an alternative to [solr](http://lucene.apache.org/solr/) or [sphinx](http://www.sphinxsearch.com/), for instance), with the added benefit that you're not running a separate daemon or search service.
* [PostGIS](http://postgis.refractions.net/) for geospacial objects.
* [There](http://pgcluster.projects.postgresql.org/) [are](http://slony1.projects.postgresql.org/) [many](http://sourceforge.net/projects/dbbalancer) [replication](http://pgpool.projects.postgresql.org/) [options](http://pg-comparator.projects.postgresql.org/), although non of them are built into the core. This will [change very soon](http://archives.postgresql.org/pgsql-hackers/2008-05/msg00913.php), though.
* You can tweak its brains out: open up postgresql.conf, and you'll find many configuration options that can be tweaked to your application load and server capabilities. If you're like me, this is lots of fun. I will say, however, that it will take time to understand many of the options and how they affect each other. 
* Excellent [documentation](http://www.postgresql.org/docs/8.4/interactive/index.html), which not only goes through the basics of setting up and using PostgreSQL, but really gets into the details of the inner workings of the system. This is an invaluable resource, not only for day-to-day development but also for tweaking the database's configuration files.
* Much more in the [contrib](http://www.postgresql.org/docs/8.4/interactive/contrib.html) packages.

### PostgreSQL License

PostgreSQL is [released under a BSD License](http://www.postgresql.org/about/licence), and as such it is truly an Open Source Project. There are many contributors to the project, both individuals who donate their time as well as companies that improve the codebase (such as [EnterpriseDB](http://www.enterprisedb.com/) and [Command Prompt](http://www.commandprompt.com/)). If you are looking for the PostgreSQL gatekeeper, you'll be chasing your tail: There's no such thing. It is truly "Free Software".

### So, what is it? MySQL or PostgreSQL?

Historically, MySQL was built with performance in mind, whereas PostgreSQL was built with features in mind. The ease of use of MySQL earned it the popularity seen on most open source web application developers. Since then, however, two things have happened: PostgreSQL has become much faster and efficient, and MySQL has become more feature-rich. In my mind, the performance or feature argument is no longer valid for web applications. Both databases have their strengths and weaknesses and as you work out an expertise on either one of them it will become a moot point. Some of the lacking MySQL features are of interest only to DBAs, not web app developers, although this may be a consideration for larger shops and deployments.

One of the major reasons for trying out PostgreSQL, regardless of it's feature set, is it's *license and community*. This can't be more true these days, when MySQL AB was consumed by Sun Microsystems, which in turn recently got acquired by Oracle. While I doubt that the product itself may die off, the fact that the copyright to the code, and the direction of the database system itself may and will be dictated by a company like Oracle is a deal breaker for me. At this point it is hard to tell if this is good or bad for MySQL and the community around it, but it definitely shows turmoil in the MySQL ecosystem. Note that I am not implying that Oracle sees MySQL as a threat to Oracle DB. In fact, I believe that MySQL satisfies a completely different niche.

On the other hand, PostgreSQL is a community effort along the same lines as the Ruby and Rails communities. This makes it a more attractive option as the direction of the project is community driven, immune to corporate politics and revenue motives.
