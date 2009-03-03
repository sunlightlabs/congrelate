require 'rubygems'
require 'sinatra'

require 'configuration'

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