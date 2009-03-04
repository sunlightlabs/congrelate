require 'activerecord'
ActiveRecord::Base

require 'sunlight'
include Sunlight

configure do
  Sunlight.api_key = 'sunlight9'
end

configure :development do
  DB_NAME = 'bigsheet_dev'
end

ActiveRecord::Base.establish_connection(
    :adapter => 'mysql',
    :username => 'bigsheet',
    :password => 'bigsheet',
    :database => DB_NAME,
    :host => 'localhost'
)