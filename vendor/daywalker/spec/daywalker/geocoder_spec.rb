require File.dirname(__FILE__) + '/../spec_helper'

describe Daywalker::Geocoder do

  describe 'locate for 110 8th St., Troy, NY 12180' do
    before do
      @geocoder = mock('geocoder')
      Graticule::Geocoder::GeocoderUs.stub!(:new).and_return(@geocoder)

      @geocoder.stub!(:locate).and_return(build_location)
    end

    it 'should return longitude -73.684236, latitude 42.731245' do
      subject.locate('110 8th St., Troy, NY 12180').should == {
        :longitude => -73.684236,
        :latitude => 42.731245
      }
    end

    it 'should use geocoder.us geocoder to locate' do
      @geocoder.should_receive(:locate).with('110 8th St., Troy, NY 12180').and_return(build_location)

      subject.locate('110 8th St., Troy, NY 12180')
    end

    def build_location
      Graticule::Location.new(:longitude => -73.684236, :latitude => 42.731245)
    end
  end

  describe 'locate an address that is fake' do
    before do
      @geocoder = mock('geocoder')
      Graticule::Geocoder::GeocoderUs.stub!(:new).and_return(@geocoder)

      @geocoder.stub!(:locate).and_raise(Graticule::AddressError)
    end

    it 'should raise AddressError' do
      lambda {
        subject.locate('zomg')
      }.should raise_error(Daywalker::AddressError)
    end
  end

end
