require 'happymapper'
require 'httparty'
require 'graticule'

require 'daywalker/base'
require 'daywalker/type_converter'
require 'daywalker/dynamic_finder_match'
require 'daywalker/district'
require 'daywalker/legislator'
require 'daywalker/geocoder'

# Daywalker is a Ruby-wrapper around the Sunlight API (http://wiki.sunlightlabs.com/Sunlight_API_Documentation). It implements all the functionality of the API related to Districts and Legislators (the Lobbyist API is considered experimental).
#
# Before using the API, you must register for an API key: http://services.sunlightlabs.com/api/register/
#
# After registering, you'll receive an email with a link to activate the key.
# 
# To begin with, here's a small example script to print out all the districts and legislators for a zipcode:
#
#   require 'rubygems'
#   require 'pp'
#   require 'daywalker'
#
#   Daywalker.api_key = 'the api key you received'
#
#   pp Daywalker::Legislator.all_by_zip(02114)
#   pp Daywalker::District.all_by_zip(02114)
#
# See Daywalker::District and Daywalker::Legislator for more details on usage.
module Daywalker
  # Set the API to be used. This must be set when using Daywalker, BadApiKeyErrors will be occur.
  def self.api_key=(api_key)
    @api_key = api_key
  end

  # Get the API to be used
  def self.api_key
    @api_key
  end

  def self.geocoder=(geocoder) # :nodoc:
    @geocoder = geocoder
  end

  def self.geocoder # :nodoc:
    @geocoder
  end

  self.geocoder = Daywalker::Geocoder.new

  # Error for when you use the API with a bad API key
  class BadApiKeyError < StandardError
  end

  # Error for when an address can't be geocoded
  class AddressError < StandardError
  end

  # Error for when an object was specifically looked for, but does not exist
  class NotFoundError < StandardError
  end
end
