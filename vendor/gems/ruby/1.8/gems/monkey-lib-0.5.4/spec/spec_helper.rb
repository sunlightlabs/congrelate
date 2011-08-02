$LOAD_PATH.unshift File.expand_path(__FILE__.sub("spec/spec_helper.rb", "lib"))
require "monkey-lib"

# I hate that code, but rbx for some reason ignores RUBYOPT.
begin
  require "rubygems"
rescue LoadError
end

BACKEND, BACKEND_SETUP = ENV['BACKEND'], ENV['BACKEND_SETUP']
if BACKEND and not BACKEND.empty?
  case BACKEND_SETUP
  when "autodetect"
    require BACKEND
    Monkey::Backend.setup
  when "explicit"
    Monkey.backend = BACKEND
  else
    puts "Please set BACKEND_SETUP."
    exit 1
  end
  version = "version " << Monkey.backend.version << ", " if Monkey.backend.version?
  puts "Using #{BACKEND} (#{version}#{BACKEND_SETUP} setup mode)"
end

Monkey.show_invisibles!
