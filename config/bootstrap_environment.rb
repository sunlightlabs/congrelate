require 'rubygems'
require 'sinatra'
gem 'activerecord', '>=2.3'
require 'activerecord'

configure do
  details = YAML.load_file('config/database.yml')[Sinatra::Application.environment]
  ActiveRecord::Base.establish_connection(details.merge(:reconnect => true))
end