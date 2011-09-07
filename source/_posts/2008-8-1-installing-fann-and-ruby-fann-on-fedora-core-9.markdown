---
layout: post
title: Installing FANN and ruby-fann on Fedora Core 9
date: 2008-08-01 11:07:30 -0400
comments: true
---

As of this writing, the ruby-fann library requires FANN 2.1.  Since that version of FANN is still in beta, it is not available from the yum repositories yet (as far as I know). Compiling the source is trivial, however:

* Download the source code for FANN 2.1beta from any of the mirrors found here: [http://leenissen.dk/fann](http://leenissen.dk/fann)

* After extracting it, run the usual:
<code>
./configure
make
sudo make install
</code>

* Make sure the files are present:
<code>ls /usr/local/lib |grep fann
libdoublefann.a
libdoublefann.la
libdoublefann.so
libdoublefann.so.2
libdoublefann.so.2.0.1
libfann.a
libfann.la
libfann.so
libfann.so.2
libfann.so.2.0.1
libfixedfann.a
libfixedfann.la
libfixedfann.so
libfixedfann.so.2
libfixedfann.so.2.0.1
libfloatfann.a
libfloatfann.la
libfloatfann.so
libfloatfann.so.2
libfloatfann.so.2.0.1</code>

Since these libraries where <em>just</em> installed, you have to run <code>ldconfig</code> in order to cache them and create the required links. This was the gotcha:
<code>ldconfig /usr/local/lib</code>

Now, use ruby-gems to install the ruby-fann bindings:

<code>sudo gem install ruby-fann</code>
