require 'rubygems'
require 'sinatra'

get '/' do
  haml :index
end

get '/results' do
  halt 401, "No"
end