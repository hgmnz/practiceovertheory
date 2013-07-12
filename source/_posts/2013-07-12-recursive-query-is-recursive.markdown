---
layout: post
title: "RECURSIVE Query is Recursive"
date: 2013-07-12 08:26
comments: true
categories: 
---

In Postgres you have the ability to write recursive queries that refer to
themselves. This is a very powerful construct, and among other use cases can
greatly simplify fetching any type of hierarchical data, such as any data where
an attribute refers to another row on the same table.

For example, a graph structure where a parent identifier refers to the an ID on
the same table. Another example can be seen on audit trail type tables,
containing prior and new versions of some value.

Let's prepare an example to show showcase recursive querying in postgres.

First, a table holding old and new email address values:

```sql
CREATE TABLE audit_trail (
  old_email TEXT NOT NULL,
  new_email TEXT NOT NULL
);
```

Now, let's populate it with some data:

```sql
INSERT INTO audit_trail(old_email, new_email)
  VALUES ('harold_gim@yahoo.com', 'hgimenez@hotmail.com'),
         ('hgimenez@hotmail.com', 'harold.gimenez@gmail.com'),
         ('harold.gimenez@gmail.com', 'harold@heroku.com'),
         ('foo@bar.com', 'bar@baz.com'),
         ('bar@baz.com', 'barbaz@gmail.com');
```

A query to find all my email addresses in one shot may look like this:

```sql
 WITH RECURSIVE all_emails AS (
  SELECT  old_email, new_email
    FROM audit_trail
    WHERE old_email = 'harold_gim@yahoo.com'
  UNION
  SELECT at.old_email, at.new_email
    FROM audit_trail at
    JOIN all_emails a
      ON (at.old_email = a.new_email)
)
SELECT * FROM all_emails;
```
```
        old_email         |        new_email
--------------------------+--------------------------
 harold_gim@yahoo.com     | hgimenez@hotmail.com
 hgimenez@hotmail.com     | harold.gimenez@gmail.com
 harold.gimenez@gmail.com | harold@heroku.com
```

A few potentially new concepts in here. First of all we have `WITH` queries,
formally called *Common Table Expressions*. CTEs can be used as a a view, but
they have the important property that they are performance gates: postgres is
guaranteed to execute each CTE in a query indepently. CTEs are much more than
a view however: they can return data from a DELETE operation that can be
consequently operated on, they can define updatable datasets, and more to the
point, they can be self-referential or recursive.

Recursive CTEs are those that refer to themselves in the body, such as the
above query. They're not really recursive, but rather iterative, but the SQL
standard is the law around here, so we live with it.

Breaking apart the above query, here's what happens:

1. `SELECT * FROM all_emails;` invokes the `all_emails` CTE.
2. `all_emails` has two parts, the non-recursive and the recursive terms,
   which are separated by the `UNION` keyword. It could also be `UNION ALL`;
   the former removes dupes and the latter doesn't. At this stage, the
   non-recursive term is executed and placed on a data structure called the _working table_.
   The working table now contains one row:

               old_email         |        new_email
       --------------------------+--------------------------
        harold_gim@yahoo.com     | hgimenez@hotmail.com

   The contents of the working table are appended to the result of the recursive
   query at this point.
3. Then the recursive term is executed, where the self-reference is
   substituted with the contents of the _working table_, placing the result
   in another data structure called an _intermediate table_. Thus, the
   intermediate table looks like so:

             old_email       |        new_email
       ----------------------+--------------------------
        hgimenez@hotmail.com | harold.gimenez@gmail.com

4. The contents of the working table are now replaced by those of the
   intermediate table, and the intermediate table is emptied.
5. Because the working table is not empty, steps 2 through 4 are repeated.
6. When the working table is empty, return the query results

Whether it's for OLTP/application usage, or for ad-hoc reporting, Recursive
CTEs can help optimize and simplify code required to get at the data you need.
To learn more about other powerful operations that can be done with CTEs, see
[the official postgres
docs](http://www.postgresql.org/docs/9.1/static/queries-with.html).

