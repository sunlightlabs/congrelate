require 'rubygems'
require 'sinatra'
gem 'activerecord', '>=2.3'
require 'activerecord'

configure do
  details = YAML.load_file 'config/database.yml'
  if details and details[Sinatra::Application.environment]
    ActiveRecord::Base.establish_connection details[Sinatra::Application.environment].merge(:reconnect => true)
  end
end