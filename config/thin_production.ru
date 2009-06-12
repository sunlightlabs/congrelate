ENV['RACK_ENV'] = 'production'

require 'congrelate'
run Sinatra::Application