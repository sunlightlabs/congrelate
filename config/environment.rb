require 'rubygems'
require 'sinatra'
require 'httparty'
require 'daywalker'
require 'activerecord'
require 'hpricot'
require 'fastercsv'

configure :production do
  DATABASE = 'bigsheet_production'
  Daywalker.api_key = '[make production key]'
  OPENSECRETS_API_KEY = 'e38f1739902531476d7d450ab966a3a7' # infinite
  OPENSECRETS_LIMIT = 
end

configure :staging do
  DATABASE = 'bigsheet_staging'
  Daywalker.api_key = 'sunlight9'
  OPENSECRETS_API_KEY = 'e38f1739902531476d7d450ab966a3a7' # infinite
  OPENSECRETS_LIMIT = 
end

configure :development do
  DATABASE = 'bigsheet_dev'
  Daywalker.api_key = 'sunlight9'
  OPENSECRETS_API_KEY = 'd55ecab9fdc27683d3512af9e2c4deb5' # limited
end

configure :test do
  DATABASE = 'bigsheet_test'
  Daywalker.api_key = '[tests should not hit any remote API]'
  OPENSECRETS_API_KEY = '[tests should not hit any remote API]'
end

ActiveRecord::Base.establish_connection(
  :adapter => 'mysql',
  :username => 'bigsheet',
  :password => 'bigsheet',
  :database => DATABASE,
  :host => 'localhost'
)

def load_models
  Dir.glob('sources/**/*.rb').each {|model| load model}
end