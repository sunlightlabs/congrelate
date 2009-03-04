#!/usr/bin/ruby

# Environment
require 'environment'

# Models
class Source < ActiveRecord::Base
end

# Load in each source
require 'sources/legislator'

# Controllers
get '/' do
  @legislator = Source.find_by_keyword 'Legislator'
  haml :index
end

get '/table' do
  @legislators = Legislator.all
  haml :table
end