---
layout: post
title: GnuPG on MacOS X (Apple Mail)
date: 2007-02-11 19:48:21 -0500
comments: true
---

* Install GnuPG. [http://macgpg.sourceforge.net/](http://macgpg.sourceforge.net/)

* Create a key pair:
** Open terminal and type: <code>gpg --gen-key</code>
** Follow on screen instructions.
** Choose a key length of 4096, and an expiration of 0 (never expires). Be patient, generating the keys took about an hour.

* Install GPGPreferences. http://macgpg.sourceforge.net/

* Go to System Preferences, and open GnuPG (located at the bottom under "Other"). Go to the keyserver tab, and check: <code>"Automatically retrieve keys from server while verifying".</code>/r <code>"Include subkeys".</code>

* Install GPG Keychain access. http://macgpg.sourceforge.net/. Open it up after the key has been generated (step 2). Import other's keys for people you will exchanged signed messages with.

* Install GnuPGMail plugin. http://www.sente.ch/software/GPGMail/English.lproj/GPGMail.html
 Open Mail, and go to preferences (Apple + ,). Defaults are fine.

* Sign and send an email.
