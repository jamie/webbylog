namespace :ann do
  desc 'Announce latest post on Twitter'
  task :tweet do
    require 'twitter'
    twitter = Twitter::Base.new(*SITE.twitter)
    article = BlogPage.new(Dir['content/blog/2*'].last)
    status = "Latest blog post: \"#{article.title}\" #{article.short_url}"
    puts status
    twitter.update(status)
  end
  
  
end
