require 'activerecord'
require 'sunlight'
include Sunlight

configure :production do
  DATABASE = 'bigsheet_production'
  Sunlight.api_key = 'sunlight9'
end

configure :development do
  DATABASE = 'bigsheet_dev'
  Sunlight.api_key = 'sunlight9'
end

configure :test do
  DATABASE = 'bigsheet_test'
  Sunlight.api_key = 'sunlight9'
end

ActiveRecord::Base.establish_connection(
    :adapter => 'mysql',
    :username => 'bigsheet',
    :password => 'bigsheet',
    :database => DATABASE,
    :host => 'localhost'
)