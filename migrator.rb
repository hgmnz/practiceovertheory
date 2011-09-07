require 'pg'
require 'active_record'
require 'active_support'

class Post < ActiveRecord::Base;
  def title_slug
    title.parameterize
  end

  def awesomeful_slug
    "#{id}-#{title.parameterize}"
  end
end
ActiveRecord::Base.establish_connection(
  database: 'awesomeful_development',
  adapter: 'postgresql'
)

def boillerplate(title, date)
  <<-END
---
layout: post
title: #{title}
date: #{date}
comments: true
---

  END
end

# Post.all.each do |post|
#   # post
#   next unless post.published_at
#   file_name = "source/_posts/#{post.published_at.year}-#{post.published_at.month}-#{post.published_at.day}-#{post.title_slug}.markdown"
#   next if (file_name =~ /in-case-you-missed-it/ || !post.published_at)
#   body = post.body
#   body.gsub!(/<highlight(?::.*?)>(.*?)<\/highlight>/, '<code>\1</code>')
#   body.gsub!(/<highlight:(.*?)>(.*?)<\/highlight>/m, '{% codeblock lang:\1 %}\2{% endcodeblock %}')
#   body.gsub!(/<highlight>(.*?)<\/highlight>/m, '<code>\1</code>')
#   File.open(file_name, 'w') do |file|
#     file.puts boillerplate(post.title, post.published_at)
#     file.puts body
#   end
# end

Post.all.each do |post|
  next unless post.published_at
  new_path = "blog/#{post.published_at.year}/0#{post.published_at.month}/#{post.created_at.day}/#{post.title_slug}"
  next if (new_path =~ /in-case-you-missed-it/ || !post.published_at)
  puts "'posts/#{post.awesomeful_slug}' => '#{new_path}'"
end

