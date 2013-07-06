---
layout: post
title: "Distributed locking in Postgres"
date: 2013-07-06 11:36
comments: true
categories: 
---

Postgres has a few handy primitives for dealing with distributed process level
locking. Because these locks are atomic and handled by the database, they are
well suited for coordinating concurrent processes' access to shared resources.

For example, a checkout endpoint on an ecommerce site should be placed behind
such an advisory lock, so that if the user initiates two check out processes
consecutively, only one occurs. Even if the two requests make it to different
web processes, the second attempt should gracefully be rolled back.

Another example can be seen in worker processes that perform some sort of
idempotent action in a loop, but for which only one process should be executing
at a time. You may spin up two such processes ensuring high availability, but
they only operate if a lock is acquired. In this way, the first process
acquires the lock, and the second blocks until either the first one releases
it, either because it crashed or it gracefully exited.

## Postgres locking

Postgres has various functions that can be used for creating locks. The topic
of this article is advisory locks. Explicit locks are those taken by database
operations such as concurrent writes, and they are guaranteed to be obeyed no
matter what. For example, one process updating a column, and another trying to
drop the very same column.

In the advisory lock case, the application requests a lock in order to perform
some operation, and releases it when it's done. It's up to the application
itself to obey this lock, hence the name.

In the advisory lock family of functions, we can categorize them as:

* _Session level_: those that affect a session or connection. When taking a
  session level lock, if a transaction fails and rolls back, the lock will
  continue to be held until it is explicitely released.
* _Transaction level_: locks that automatically get released at the end of a
  transaction. In many cases the semantics offered by transaction level locking
  are a better fit for the underlying problem. In general, if the action being
  performed is wrapped in a transaction, this is likely the best suited locking
  scope.

Beyond the above, locks can be blocking or non-blocking. In the blocking case,
the request for a lock will wait until it can be obtained, whereas in the non-blocking
case the request returns immediately but returns false.

## Usage examples

### Session level

Let's look at session level locks first. Opening up two psql sessions we can
experiment with the locking semantics:

```sql psql session 1
SELECT pg_advisory_lock(1);
 pg_advisory_lock
------------------

(1 row)
```

```sql psql session 2
SELECT pg_advisory_lock(1);

```
Here, session 2 just blocks until the lock is acquired. On a third session we
can check in pg_locks and pg_stat_activity to verify this:

```sql psql session 3
select pg_locks.granted,
       pg_stat_activity.query,
       pg_stat_activity.query_start
       from pg_locks
  JOIN pg_stat_activity
    on pg_locks.pid = pg_stat_activity.pid
  WHERE pg_locks.locktype = 'advisory';
 granted |            query            |          query_start
---------+-----------------------------+-------------------------------
 t       | SELECT pg_advisory_lock(1); | 2013-07-06 10:59:31.559991-07
 f       | SELECT pg_advisory_lock(1); | 2013-07-06 11:00:09.412517-07
(2 rows)
```

Now, let's release the lock on session 1:

```sql psql session 1
select pg_advisory_unlock(1);
 pg_advisory_unlock
--------------------
 t
(1 row)
```

Pretty much immediately after having done this, session 2 took the lock, and it
looks like this:

```sql psql session 2
SELECT pg_advisory_lock(1);
 pg_advisory_lock
------------------

(1 row)

Time: 381445.570 ms
```

And now pg_locks shows the on lock being held

```sql psql session 3
select pg_locks.granted,
       pg_stat_activity.query,
       pg_stat_activity.query_start
       from pg_locks
  JOIN pg_stat_activity
    on pg_locks.pid = pg_stat_activity.pid
  WHERE pg_locks.locktype = 'advisory';
 granted |            query            |          query_start
---------+-----------------------------+-------------------------------
 t       | SELECT pg_advisory_lock(1); | 2013-07-06 11:00:09.412517-07
(1 row)
```

Because this is a session level lock, failing or rolling back any transaction
while holding a lock does not release the lock at all. Only explicitely unlocking
or disconnecting the client would release the lock.

### Transaction level

Now let's take a look at how transaction level locks work:

```sql psql session 1
BEGIN;
SELECT pg_try_advisory_xact_lock(1);
 pg_try_advisory_xact_lock
---------------------------
 t
(1 row)
```

Note also that we're using the `try` variant of locking functions. Instead of
blocking on a lock to be obtained, the `try` variants return true or false
depending on whether a lock could be obtained.

On session 2, we can try grabbing a lock as well:

```sql psql session 2
BEGIN;
SELECT pg_try_advisory_xact_lock(1);
 pg_try_advisory_xact_lock
---------------------------
 f
(1 row)
```

It returned false, because the first session already has said lock. If we were
to complete this transaction either by failing, a COMMIT or a ROLLBACK, then
this lock can be acquired. Let's try that:

```sql psql session 1
ROLLBACK;
```

After exiting the transaction on one session, the other ought to be able to
acquire it:

```sql psql session 2
 SELECT pg_try_advisory_xact_lock(1);
 pg_try_advisory_xact_lock
---------------------------
 t
(1 row)
```

All postgres locking functions take an application defined key in the form of
one 64-bit integers or two 32-bit integers. An application may create CRC
values from higher level abstractions. For example, a suitable integer for a
lock on user ID 4232 may be the CRC of the string "user4232". This pattern is
implemented in the [lock
smith](https://github.com/ryandotsmith/lock-smith/blob/master/lib/locksmith/pg.rb#L22-L30)
ruby library, and works well as an easy to understand application level
abstraction.

### Conclusion

Applications in modern software development and delivery are distributed in
nature. Distributed mutexes and locks are an important primitive to help
ensure correctness of behavior under concurrent environments.

Many projects and products with distributed lock managers exist such as but
Postgres provides a lightweight mechanism that is suitable for many locking
needs, without needing to add more dependencies to infrastructure which already
uses Postgres.

More information about advisory locks in postgres can be found [here](http://www.postgresql.org/docs/9.1/static/functions-admin.html#FUNCTIONS-ADVISORY-LOCKS) and [here](http://www.postgresql.org/docs/9.1/static/explicit-locking.html#ADVISORY-LOCKS).

