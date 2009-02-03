namespace :blog do
  desc 'Create a new draft titled [NAME]'
  task :new, :title do |task, args|
    title = args[:title]
    basename = title.downcase.gsub(/[^a-z0-9]+/, '-')
    target = File.join('blog', 'draft-' + basename + ".#{BLOG_EXT}")
    
    result = Webby::Builder.create(
      target,
      :from => 'templates/blog.md',
      :locals => {:title => title, :basename => basename}
    )
    unless Webby.editor.nil?
      editor = Webby.editor
      editor = 'mate' if editor == 'mate -w'
      `#{editor} #{result}`
    end
  end
  
  desc 'List current draft posts'
  task :drafts do
    Dir['content/blog/draft*'].each_with_index do |draft, id|
      page = BlogPage.new(draft)
      puts "%2d  %s" % [id, page.title]
    end
  end
  
  desc 'Publish draft #N (see blog:drafts)'
  task :publish, :draft_id do |task, args|
    page = BlogPage.new(Dir['content/blog/draft*'][args[:draft_id].to_i])
    page.publish_to('content/blog')
  end
  
  desc 'Publish draft #N (see blog:drafts), then publish site'
  task :publish!, :draft_id do
    Rake::Task['blog:publish'].invoke
    Rake::Task['publish!'].invoke
  end
end
