require 'rubygems'
require 'spec'
require 'yaml'
require 'fake_web'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.dirname(__FILE__), '..', 'lib')

require 'daywalker'

FakeWeb.allow_net_connect = false

module Daywalker
  module ExampleMethods
    def fixture_path_for(response)
      File.join File.dirname(__FILE__), 'fixtures', response
    end

    def register_uri_with_response(uri, response)
      FakeWeb.register_uri("http://services.sunlightlabs.com/api/#{uri}", :response => fixture_path_for(response))
    end

    def yaml_fixture(name)
      YAML::load_file File.join(File.dirname(__FILE__), 'fixtures', name)
    end
  end

  module ExampleGroupMethods

    def specify_its_attributes(attributes)
      attributes.each do |name, value|
        specify { subject.send(name.to_sym).should == value }
      end
    end

  end
end

Spec::Runner.configure do |config|
  config.before :each do
    FakeWeb.clean_registry
  end

  config.before :all do
    Daywalker.api_key = 'redacted'
  end

  config.after :all do
    Daywalker.api_key = nil
  end

  config.include Daywalker::ExampleMethods
  config.extend Daywalker::ExampleGroupMethods
end

