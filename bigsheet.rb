#!/usr/bin/ruby

# Environment
require 'environment'

# Models
class Source < ActiveRecord::Base
end

# Load in each source
configure do
  Source.all.each do |source| 
    begin
      require "sources/#{source.keyword}"
    rescue MissingSourceFile
      nil
    end
  end
end

# Controllers
get '/' do
  haml :index
end

get '/table' do
  @legislators = Legislator.all
  haml :table
end