ENV['RACK_ENV'] = 'staging'

require 'bigsheet'

run Sinatra::Application
