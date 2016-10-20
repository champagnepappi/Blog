require 'sinatra/base' 
require 'github_hook'
require 'ostruct'
require 'time'

class Blog < Sinatra::Base
  use GithubHook
  #File.expand_path generates an absolute path
  #Also takes a path as second argument
  #The generated path is treated as being
  #relative to that path
  set :root, File.expand_path('../../',_FILE_)
  set :articles, [] #loop through all the article files
  set :app_file, _FILE_

  Dir.glob "#{root}/articles/*.md" do |file|
    #parse meta data and contents from file
    meta, content = File.read(file).split("\n\n",2)

    #generate metadata object
    article = OpenStruct.new YAML.load(meta)

    #convert date to a time object
    article.date = Time.parse article.date.to_s

    #add the content
    article.content = content

    #generate slug for the url
    article.slug = File.basename(file,'.md')

    #setup the route
    get "/#{article.slug}" do
      erb :post, :locals => { :article => article }
    end

    #add articles to the list of article
    articles << article
  end

    #sort articles by date, display new articles first
    articles.sort_by! { |article| article.date }
    articles.reverse!

    get '/' do
      erb :index
    end
end
