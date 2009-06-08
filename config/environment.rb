require 'rubygems'
require 'sinatra'
gem 'activerecord', '>=2.3'
require 'activerecord'

configure do
  details = YAML.load_file('config/database.yml')[Sinatra::Application.environment]
  ActiveRecord::Base.establish_connection(details.merge(:reconnect => true))
end

### Below can't be run until initial rake db:migrate

class Source < ActiveRecord::Base; end
class Update < ActiveRecord::Base; validates_presence_of :status, :source, :elapsed_time; end

api_keys = YAML.load_file('sources/api_keys.yml')[Sinatra::Application.environment]
sources = Source.all
sources.each do |source|
  Dir.glob(File.join('sources', source.keyword, '*.rb')).each {|model| load model}
  source_class = source.keyword.camelize.constantize
  source_class.class_eval <<-EOC
    def self.api_key; "#{api_keys[source.keyword.to_sym]}"; end
    def self.for_form; self.respond_to?(:form_data) ? form_data : {}; end
  EOC
  
  get "/#{source.keyword}/form" do
    erb :form, :layout => false, :locals => {:source => source, :options => source_class.for_form}
  end
end