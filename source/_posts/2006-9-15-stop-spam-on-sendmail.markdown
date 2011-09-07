---
layout: post
title: Stop spam on sendmail
date: 2006-09-15 22:50:44 -0400
comments: true
---

Lately the number of spam messages has grown very rapidly on my organization's sendmail server. There's a few things you can do. Here are two which helped considerably:

1. <strong>Deny access to the domain</strong>: You can add the domain name to <code>/etc/mail/access</code> followed by the word <code>REJECT</code>. After editing the access file, you have to run <code>make</code> on the <code>/etc/mail</code> directory.

2. <strong>Use online spam blacklists</strong>: There are many of these lists, such as [Spamhaus ROKSO](http://www.spamhaus.org/rokso/index.lasso), [Spamcop](http://www.spamcop.net/), or the [Open Relay Database](http://www.ordb.org/). These are organizations that basically provide a list of spammers. Many thanks to all of you!.
 To use their lists on sendmail, add the following lines to your <code>/etc/mail/sendmail.mc</code> file before the <code>MAILER</code> lines:

<code>FEATURE(`dnsbl',`relays.ordb.org', `Rejected - see http://ordb.org/')dnl
FEATURE(`dnsbl',`bl.spamcop.net',`Rejected - see http://spamcop.net/')dnl
FEATURE(`dnsbl',`sbl.spamhaus.org',`Rejected - see http://www.spamhaus.org/')dnl</code>
After editing sendmail.mc, you have to rebuild sendmail.cf. Here's how I did it:
<code>$ cp /etc/mail/sendmail.mc .
$ m4 ../m4/cf.m4 sendmail.mc > sendmail.cf
$ cp /etc/mail/sendmail.cf /etc/mail/sendmail.cf.BAK
$ cp sendmail.cf /etc/mail/sendmail.cf
$ cp: overwrite `/etc/mail/sendmail.cf'? y
$ /etc/rc.d/init.d/sendmail restart
</code>

Any more ideas to stop spammers? I honestly do not understand why these people keep spamming. Problems man, serious problems! Don't they realize that there is no way people will read their emails, not to mention buy their products or fall for their scams? Or will they?
