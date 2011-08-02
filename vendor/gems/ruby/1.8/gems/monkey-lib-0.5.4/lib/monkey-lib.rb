require "monkey"

unless defined? Monkey
  warn "installing both the monkey and the monkey-lib gem results in conflicts, add a Gemfile, use gemsets or remove monkey gem"
  $LOADED_FEATURES.delete_if { |l| l =~ /monkey\.rb$/ }
  if defined? require_relative
    require_relative "monkey"
  else
    $LOAD_PATH.unshift File.expand_path('..', __FILE__)
    require 'monkey'
  end
  fail "Please remove monkey gem (not monkey-lib gem) from your $LOAD_PATH" unless defined? Monkey
end

MonkeyLib = Monkey
