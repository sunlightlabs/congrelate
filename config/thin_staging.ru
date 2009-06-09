ENV['RACK_ENV'] = 'staging'

require 'congrelate'

run Sinatra::Application
