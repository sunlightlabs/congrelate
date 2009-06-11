module Daywalker
  class Geocoder # :nodoc:

    def locate(address)
      location = geocoder.locate(address)
      { :longitude => location.longitude, :latitude => location.latitude }
    rescue Graticule::AddressError => e
      raise Daywalker::AddressError, e.message
    end

    private

    def geocoder
      Graticule.service(:geocoder_us).new
    end

  end
end
