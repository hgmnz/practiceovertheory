---
layout: post
title: Cannot connect to SQL Server 2005 Express
date: 2007-11-28 16:09:52 -0500
comments: true
---

(Very old news, but I keep having to go back to this)

If your SQL client (ie: SQL Server Mangement Studio, Toad, Embarcadero, etc) can't connect to a MS SQL Server 2005 Express Edition installation, follow these steps:

* Launch `SQL Server Configuration Manager`

* Click on `SQL Server 2005 Network Configuration`

* Click on `Protocols for MSSERVER` => `right click on TCP/IP` => `properties`

* Click on `Protocols`, make sure it is enabled

* Click on `IP Addresses` and make sure under each of the `IP1`, `IP2` and `IPAll`, that the port is `1433`

* Click on `SQL Native Client Configuration`

* Click on `Client protocols` => `TCP/IP` => right click => `Properties` => make sure the `port` is `1433`

* Right click on `Alias` => `New alias` => `Alias`: `any name`. Port`: `1433`. `Server`: host name for the SQL Server Express instance

* Try to connect
