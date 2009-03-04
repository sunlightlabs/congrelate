require 'rubygems'
require 'sinatra'
require 'daywalker'
require 'activerecord'

configure :production do
  DATABASE = 'bigsheet_production'
  Daywalker.api_key = 'sunlight9'
end

configure :development do
  DATABASE = 'bigsheet_dev'
  Daywalker.api_key = 'sunlight9'
end

configure :test do
  DATABASE = 'bigsheet_test'
  Daywalker.api_key = 'sunlight9'
end

ActiveRecord::Base.establish_connection(
  :adapter => 'mysql',
  :username => 'bigsheet',
  :password => 'bigsheet',
  :database => DATABASE,
  :host => 'localhost'
)