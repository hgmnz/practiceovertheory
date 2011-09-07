---
layout: post
title: Attach non image files in Rails with paperclip
date: 2009-05-19 18:40:10 -0400
comments: true
---

Paperclip has pretty much become the standard when it comes to attaching files to models in Rails. It has a very easy to use API, allows the user to [create her own post-processing code](http://dev.thoughtbot.com/paperclip/classes/Paperclip/Processor.html) (such as OCR or others), and provides callbacks for before and after post-processing.This post does not cover getting started with paperclip. There are plenty of other posts that cover that. The intent is to get you up and running on using paperclip to attach non-image files.

Out of the box, the default post processor invoked upon upload is the <a href="http://dev.thoughtbot.com/paperclip/classes/Paperclip/Thumbnail.html">Paperclip::Thumbnail</a> processor. This processor creates thumbnails of an image based on the styles hash passed to the <code>has_attached_file</code> method. If you want to upload word documents, excel files, and other non-image data, the Thumbnail processor will fail, and the attachment will not succeed. This processor does not check if the file itself is an image, and tries to call ImageMagick's identify command on the file anyways.

Paperclip makes solving this extremely simple: prevent the post processing from happening when the file is not an image. Just like on <code>ActiveRecord</code> callbacks, you can return false on paperclip's <code class="inline_code">before_post_process</code> callback to avoid the processing from happening in the first place. 

One possible solution is to put the following in whatever model you're using paperclip on:

{% codeblock lang:ruby %}before_post_process :image?
def image?
  !(data_content_type =~ /^image.*/).nil?
end{% endcodeblock %}

In this case, we've created an image? method which returns true if the content type starts with the string image (as in 'image/png', 'image/jpeg', etc). What's neat about this is that this same method can be used in your views to either render an <code>image_tag</code>, or something else such as an icon or the file's name, depending on whether the file is an image.
