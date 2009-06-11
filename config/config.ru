ENV['RACK_ENV'] = 'production'

require 'rubygems'
%w{rack sinatra activerecord daywalker fastercsv hpricot htmlentities httparty json}.each do |gem_name|
  require "vendor/#{gem_name}/lib/#{gem_name}"
end

require 'congrelate'
run Sinatra::Application
