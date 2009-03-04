#!/usr/bin/ruby

require 'rubygems'
require 'sinatra'

require 'configuration'

get '/' do
  haml :index
end

get '/table' do
  haml :table
end