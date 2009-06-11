module Daywalker
  # Represents a Congressional district.
  #
  # They have the following attributes:
  # * number
  # * state (as a two-letter abbreviation)
  class District < Base
    include HappyMapper

    tag     'district'
    element 'number', Integer
    element 'state', String

    # Find the district for a specific latitude and longitude.
    #
    # Returns a District. Raises ArgumentError if you omit latitude or longitude.
    def self.unique_by_latitude_and_longitude(latitude, longitude)
      raise(ArgumentError, 'missing required parameter latitude') if latitude.nil?
      raise(ArgumentError, 'missing required parameter longitude') if longitude.nil?

      query = {
        :latitude => latitude,
        :longitude => longitude,
        :apikey => Daywalker.api_key
      }
      response = get('/districts.getDistrictFromLatLong.xml', :query => query)
      handle_response(response).first
    end

    # Finds all districts for a specific zip code.
    #
    # Returns an Array of Districts. Raises ArgumentError if you omit the zip.
    def self.all_by_zipcode(zip)
      raise(ArgumentError, 'missing required parameter zip') if zip.nil?

      query = {
        :zip => zip,
        :apikey => Daywalker.api_key
      }
      response = get('/districts.getDistrictsFromZip.xml', :query => query)

      handle_response(response)
    end

    # Find the district for a specific address.
    #
    # Returns a District.
    #
    # Raises Daywalker::AddressError if the address can't be geocoded.
    def self.unique_by_address(address)
      raise(ArgumentError, 'missing required parameter address') if address.nil?
      location = Daywalker.geocoder.locate(address)

      unique_by_latitude_and_longitude(location[:latitude], location[:longitude])
    end

    def initialize(attributes = {})
      attributes.each do |attribute, value|
        send("#{attribute}=", value)
      end
    end

    def legislators
      @legislators ||= begin
        representative = Legislator.unique_by_state_and_district(state, number)
        junior_senator = Legislator.unique_by_state_and_district(state, :junior_seat)
        senior_senator = Legislator.unique_by_state_and_district(state, :senior_seat)

        {
          :representative => representative,
          :junior_senator => junior_senator,
          :senior_senator => senior_senator
        }
      end
    end
  end
end
