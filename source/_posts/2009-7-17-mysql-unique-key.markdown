---
layout: post
title: MySQL unique key
date: 2006-08-17 15:08:00 -0400
comments: true
---

#### How to avoid table scans in MySQL

Let's start out by showing what the table I'm referring to looks like:

{% codeblock lang:sql %}
mysql> describe Readings;
 +----------------+------------------+------+-----+------------+-------+
 | Field          | Type             | Null | Key | Default    | Extra |
 +----------------+------------------+------+-----+------------+-------+
 | concentratorID | int(2) unsigned  |      | | 0          |       |
 | sensorID       | int(11) unsigned |      | | 0          |       |
 | channel        | char(2)          | YES  |     | NULL       |       |
 | date           | date             |      | | 0000-00-00 |       |
 | time           | time             |      | | 00:00:00   |       |
 | value          | double           | YES  |     | NULL       |       |
 | type           | varchar(8)       |      |     |            |       |
 | SWVersion      | varchar(15)      | YES  |     | NULL       |       |
 +----------------+------------------+------+-----+------------+-------+
 8 rows in set (0.00 sec)

 mysql&gt; select count(*) from Readings;
 +----------+
 | count(*) |
 +----------+
 |   728477 |
 +----------+{% endcodeblock %}

Basically this table holds data for sensor readings and keeps date/time stamps for them. It contains over 700 thousand rows.
 Have a look at the query below:
{% codeblock lang:sql %}
mysql> SELECT DATE_FORMAT(t1.date, '%b %D, %y') as Date, t1.time as Time, t1.value as "South External" , t2.value as "South Internal" FROM Readings AS t1 , Readings AS t2 WHERE t1.date = t2.date AND t1.time = t2.time AND t1.sensorID=38 AND t2.sensorID=36 ORDER BY t1.date DESC, t1.time DESC LIMIT 5;
 +--------------+----------+----------------+----------------+
 | Date         | Time     | South External | South Internal |
 +--------------+----------+----------------+----------------+
 | Aug 17th, 06 | 08:20:40 |         21.375 |         21.375 |
 | Aug 17th, 06 | 08:10:31 |        22.6875 |        21.4375 |
 | Aug 17th, 06 | 08:00:22 |          22.25 |         21.375 |
 | Aug 17th, 06 | 07:50:12 |         20.875 |        21.3125 |
 | Aug 17th, 06 | 07:40:03 |        21.0625 |         21.375 |
 +--------------+----------+----------------+----------------+
 5 rows in set (33.85 sec)
{% endcodeblock %}

Over *33 Seconds!??* Unacceptable. What's happening here is that MySQL has to scan the entire table in order to identify and match all of the dates and times in the WHERE clause of the query.

For this application, we know that one sensor reading only occurs once at a given date and time, so we can create a unique key using those columns:

{% codeblock lang:sql %}
mysql> alter table Readings add UNIQUE report_index (sensorID, date, time);
Query OK, 602969 rows affected (11.91 sec)
Records: 602969  Duplicates: 0  Warnings: 0
mysql> SELECT DATE_FORMAT(t1.date, '%b %D, %y') as Date, t1.time as Time, t1.value as "South External" , t2.value as "South Internal" FROM Readings AS t1 , Readings AS t2 WHERE t1.date = t2.date AND t1.time = t2.time AND t1.sensorID=38 AND t2.sensorID=36 ORDER BY t1.date DESC, t1.time DESC LIMIT 5;
 +--------------+----------+----------------+----------------+
 | Date         | Time     | South External | South Internal |
 +--------------+----------+----------------+----------------+
| Aug 17th, 06 | 08:30:49 |          20.75 |        21.3125 |
| Aug 17th, 06 | 08:20:40 |         21.375 |         21.375 |
| Aug 17th, 06 | 08:10:31 |        22.6875 |        21.4375 |
| Aug 17th, 06 | 08:00:22 |          22.25 |         21.375 |
| Aug 17th, 06 | 07:50:12 |         20.875 |        21.3125 |
+--------------+----------+----------------+----------------+
5 rows in set (0.00 sec) 
{% endcodeblock %}

Ahhhh... much better: 0.00 seconds people! 
