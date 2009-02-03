BLOG_EXT = "md"

require 'httparty'

class Rubyurl
  include HTTParty
  base_uri 'rubyurl.com'
 
  def self.shorten( website_url )
    post( '/api/links.json', :query => { :link => { :website_url => website_url } } )
  end
end

class BlogPage
  def initialize(filename)
    @original_filename = filename
    _, headers, @body = File.read(filename).split(/--- *\r?\n/)
    @headers = YAML.load(headers)
  end
  
  def title
    @headers['title']
  end
  
  def url
    url = SITE.http_root
    url += @headers['directory'] + '/'
    url += @headers['filename']
    url += '.' + @headers['extension'] unless @headers['extension'].blank?
    url
  end
  
  def short_url
    Rubyurl.shorten(url)['link']['permalink']
  end
  
  def headers
    ([
      "title:      #{@headers['title']}",
      "created_at: #{@headers['created_at']}",
      "tags:       [#{@headers['tags'].join(', ')}]",
      "",
      "directory:  #{@headers['directory']}",
      "filename:   #{@headers['filename']}",
      "extension:  #{@headers['extension']}",
      "",
      "layout:     #{@headers['layout']}",
      "filter:     "
    ] + @headers['filter'].map{|f| "  - #{f}"} + [""]).join("\n")
  end
  
  def filename
    "#{@headers['directory']}-#{@headers['filename']}.#{BLOG_EXT}"
  end
  
  def delete
    FileUtils.rm(@original_filename)
  end
  
  def publish
    @headers['created_at'] = Time.now.strftime('%Y-%m-%d %H:%M:%S %z')
    @headers['directory'] = Time.now.strftime('%Y-%m-%d')
  end
  
  def publish_to(target_dir)
    publish
    File.open(File.join(target_dir, filename), 'w') do |outfile|
      outfile << ['', headers, @body].join("---\n")
    end
    delete
  end
end
