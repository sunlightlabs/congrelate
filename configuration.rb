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

# Load in each source
Source.all.each do |source| 
  begin
    require "sources/#{source.keyword}"
  rescue MissingSourceFile
    nil
  end
end