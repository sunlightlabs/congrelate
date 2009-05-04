require 'rubygems'
require 'sinatra'

require 'httparty'
require 'daywalker'
gem 'activerecord', '>=2.3'
require 'activerecord'
require 'hpricot'
require 'fastercsv'

set :views, File.dirname(__FILE__) + "/.."

configure do
  details = YAML.load_file('config/database.yml')[Sinatra::Application.environment]
  ActiveRecord::Base.establish_connection(
    :adapter => 'mysql',
    :reconnect => true,
    :username => details[:username],
    :password => details[:password],
    :database => details[:database],
    :host => details[:host]
  )
end

class Source < ActiveRecord::Base; end
class Update < ActiveRecord::Base; validates_presence_of :status, :source, :elapsed_time; end

def load_sources
  api_keys = YAML.load_file('sources/api_keys.yml')[Sinatra::Application.environment]
  Dir.glob('sources/*').reject {|file| file.include? '.yml'}.each do |dir|
    Dir.glob(File.join(dir, '*.rb')).each {|model| load model}
    keyword = dir.gsub 'sources/', ''
    keyword.camelize.constantize.class_eval <<-EOC
      def self.api_key; "#{api_keys[keyword.to_sym]}"; end
    EOC
  end
end