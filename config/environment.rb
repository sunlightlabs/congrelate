require 'rubygems'
require 'sinatra'
gem 'activerecord', '>=2.3'
require 'activerecord'

class Source < ActiveRecord::Base; end
class Update < ActiveRecord::Base; validates_presence_of :status, :source, :elapsed_time; end

configure do
  details = YAML.load_file('config/database.yml')[Sinatra::Application.environment]
  ActiveRecord::Base.establish_connection(details.merge(:reconnect => true))
end

def load_sources
  api_keys = YAML.load_file('sources/api_keys.yml')[Sinatra::Application.environment]
  Source.all.each do |source|
    
    Dir.glob(File.join('sources', source.keyword, '*.rb')).each {|model| load model}
    source.keyword.camelize.constantize.class_eval <<-EOC
      def self.api_key; "#{api_keys[source.keyword.to_sym]}"; end
    EOC
  end
end

