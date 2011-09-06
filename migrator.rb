require 'pg'
require 'active_record'

class Post < ActiveRecord::Base;
  def title_slug
    title.parameterize
  end
end
ActiveRecord::Base.establish_connection(
  database: 'awesomeful_development',
  adapter: 'postgresql'
)

Post.all.each do |post|
  # post
  file_name = "source/_posts/#{post.created_at.year}-#{post.created_at.month}-#{post.created_at.day}-#{post.title_slug}.markdown"
  next if file_name =~ /in-case-you-missed-it/
  puts file_name
  body = post.body
  body.gsub!(/<highlight(?::.*?)>(.*?)<\/highlight>/, '<code>\1</code>')
  body.gsub!(/<highlight:(.*?)>(.*?)<\/highlight>/m, '{% codeblock lang:\1 %}\2{% endcodeblock %}')
  body.gsub!(/<highlight>(.*?)<\/highlight>/m, '<code>\1</code>')
  File.open(file_name, 'w') do |file|
    file.write body
  end
end
