#!/usr/bin/ruby

require 'rubygems'
require 'sinatra'
require 'daywalker'

# Models
require 'activerecord'
class Source < ActiveRecord::Base
end

# Configuration
require 'configuration'

# Controllers
get '/' do
  haml :index
end

get '/table' do
  @legislators = Legislator.all
  haml :table
end