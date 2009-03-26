require 'rubygems'
require 'sinatra'
require 'httparty'
require 'daywalker'
require 'activerecord'
require 'hpricot'
require 'fastercsv'

def database(environment)
  details = YAML.load_file('config/database.yml')[environment.to_s]
  ActiveRecord::Base.establish_connection(
    :adapter => 'mysql',
    :reconnect => true,
    :username => details[:username],
    :password => details[:password],
    :database => details[:database],
    :host => details[:host]
  )
end

configure :production do
  Daywalker.api_key = '[make production key]'
  OPENSECRETS_API_KEY = 'e38f1739902531476d7d450ab966a3a7' # infinite
end

configure :staging do
  Daywalker.api_key = 'sunlight9'
  OPENSECRETS_API_KEY = 'e38f1739902531476d7d450ab966a3a7' # infinite
end

configure :development do
  Daywalker.api_key = 'sunlight9'
  OPENSECRETS_API_KEY = 'd55ecab9fdc27683d3512af9e2c4deb5' # limited
end

configure :test do
  Daywalker.api_key = '[tests should not hit any remote API]'
  OPENSECRETS_API_KEY = '[tests should not hit any remote API]'
end

configure do
  database Sinatra::Application.options.environment
end

def load_models
  Dir.glob('sources/**/*.rb').each {|model| load model}
end