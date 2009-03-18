#!/usr/bin/ruby

require 'rubygems'
require 'sinatra'

# Environment
require 'config/environment'

# Models
load_models

# Controllers
get '/' do
  haml :index
end

get '/table' do
  @legislators = Legislator.active
  @data = get_columns @legislators
  haml :table
end

helpers do

  def get_columns(legislators)
    data = {}
    source_keys.each do |source|
      if params[source]
        if source_data = class_for(source).data_for(legislators, params[source])
          data[source] = source_data
        end
      end
    end
    data
  end
  
  def class_for(source)
    source.to_s.camelize.constantize
  end
  
  def sort_fields(fields, source)
    class_for(source).sort(fields)
  end
  
  def sources
    @@sources ||= Source.all
  end
  
  def source_keys
    sources.map {|source| source.keyword.to_sym}
  end
  
  def sort_by_ref(array, reference)
    array.sort {|a, b| reference.index(a) <=> reference.index(b)}
  end
  
end