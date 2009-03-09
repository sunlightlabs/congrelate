#!/usr/bin/ruby

require 'rubygems'
require 'sinatra'

# Environment
require 'environment'

# Models
Dir.glob('models/*.rb').each {|model| load model}

# Controllers
get '/' do
  haml :index
end

get '/table' do
  @data = get_columns
  @legislators = Legislator.active
  haml :table
end

helpers do

  def get_columns
    data = {}
    [:legislator].each do |source|
      if params[source]
        data[source] = class_for(source).data_for params[source]
      end
    end
    data
  end
  
  def class_for(source)
    source.to_s.camelize.constantize
  end
  
  def sort_fields(fields, source)
    fields.sort {|a, b| class_for(source).fields.index(a) <=> class_for(source).fields.index(b)}
  end

end