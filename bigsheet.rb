require 'rubygems'
require 'sinatra'
require 'sunlight'

include Sunlight

get '/' do
  haml :index
end

get '/table' do
  
  if params[:house] == 'representatives'
    @legislators = REPS
  elsif params[:house] == 'senators'
    @legislators = SENATORS
  else # params[:house] == 'both'
    @legislators = REPS + SENATORS
  end
  
  haml :table
end

configure do
  Sunlight.api_key = 'sunlight9'
  SENATORS = Legislator.all_where :title => 'Sen'
  REPS = Legislator.all_where :title => 'Rep'
end