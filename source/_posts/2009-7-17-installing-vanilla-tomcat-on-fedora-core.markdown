---
layout: post
title: Installing vanilla Tomcat on Fedora Core
date: 2006-08-21 07:51:00 -0400
comments: true
---

1. *Install Sun JDK*
This is quite straight forward if you follow the instructions at the unofficial fedora Faq, steps 1 through 11, located at http://www.fedorafaq.org/#java
1. *Compile and Install Tomcat 5*
This is based on the instructions provided by the Apache foundation located [here](http://tomcat.apache.org/tomcat-5.5-doc/setup.html).
   1. *Download the tarball*: I downloaded the Core version 5.5.16 from [here](http://apache.mirrormax.net/tomcat/tomcat-5/v5.5.16/bin/apache-tomcat-5.5.16.tar.gz).
   1. *Copy the tarball to /opt*: I used /opt to install it, but you can choose any other directory. /opt makes a lot of sense though!
   1. *Untar it*  with the command
<code>gunzip -c apache-tomcat-5.5.16.tar.gz |tar -xf -</code>

The folder created is what Apache calls "CATALINA_HOME", so in this case it is<code>/opt/apache-tomcat-5.5.16</code>
1. Type the following commands to *build it*:

<highglight>$ cd /opt/apache-tomcat-5.5.16/bin/
$ tar xvfs jsvc.tar.gz/r cd jsvc-src/
$ chmod +x *
$ ./configure --with-java=/usr/lib/jvm/jre-1.5.0-sun/
$ make/r cp jsvc ..</highlight>

1. *Smile*

Now you can start it by running <code>startup.sh</code> from the <code>/bin</code> directory (relative to *CATALINA_HOME*), stop it with <code>shutdown.sh</code>, dump your application into <code>webapps</code>, etc, etc, etc.

By the way, you can have your entire system using your fresh installation of the JDK by using "alternatives"

<code>su -
alternatives --config java

 There are 2 programs which provide 'java'.

 Selection    Command
-----------------------------------------------
 1           /usr/lib/jvm/jre-1.4.2-gcj/bin/java
 *+ 2           /usr/lib/jvm/jre-1.5.0-sun/bin/java

 Enter to keep the current selection[+], or type selection number:</code>

At this point, type <code>2</code>, then <code>enter</code>.

You can make it start on boot by doing <a href="http://labnotesh.wordpress.com/2006/08/21/run-commands-on-boot-for-fedora-core/">this</a>. 
