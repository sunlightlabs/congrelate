require File.dirname(__FILE__) + '/../spec_helper'

describe Daywalker::District do
  describe 'parsed from xml' do
    before do
      @xml = <<-XML
        <district>
          <state>NC</state>
          <number>4</number>
        </district>
      XML
    end
    subject { Daywalker::District.parse(@xml) }

    specify_its_attributes :state => 'NC', :number => 4
  end

  describe 'unique_by_latitude_and_longitude' do
    describe 'happy path' do
      before do
        # curl -i "http://services.sunlightlabs.com/api/districts.getDistrictFromLatLong.xml?apikey=urkeyhere&latitude=40.739157&longitude=-73.990929" > districts_by_latlng.xml
        register_uri_with_response 'districts.getDistrictFromLatLong.xml?apikey=redacted&latitude=40.739157&longitude=-73.990929', 'districts_by_latlng.xml'
        @district = Daywalker::District.unique_by_latitude_and_longitude(40.739157, -73.990929)
      end

      it 'should return NY district 4' do
        @district.state.should == 'NY'
        @district.number.should == 14
      end
    end

    describe 'bad api key' do
      before do
        # curl -i "http://services.sunlightlabs.com/api/districts.getDistrictFromLatLong.xml?apikey=badkeyhere&latitude=40.739157&longitude=-73.990929" > 'districts_by_latlng_bad_api.xml'
        register_uri_with_response('districts.getDistrictFromLatLong.xml?apikey=redacted&latitude=40.739157&longitude=-73.990929', 'districts_by_latlng_bad_api.xml')
      end

      specify 'should raise Daywalker::BadApiKeyError' do
        lambda {
          Daywalker::District.unique_by_latitude_and_longitude(40.739157, -73.990929)
        }.should raise_error(Daywalker::BadApiKeyError)
      end
    end

    describe 'missing latitude' do
      specify 'should raise ArgumentError for latitude' do
        lambda {
          Daywalker::District.unique_by_latitude_and_longitude(nil, -73.990929)
        }.should raise_error(ArgumentError, /latitude/)
      end
    end

    describe 'missing longitude' do
      specify 'should raise ArgumentError for longitude' do
        lambda {
          Daywalker::District.unique_by_latitude_and_longitude(40.739157, nil)
        }.should raise_error(ArgumentError, /longitude/)
      end
    end
  end

  describe 'all_by_zipcode' do
    describe 'happy path' do
      setup do
        # curl -i "http://services.sunlightlabs.com/api/districts.getDistrictsFromZip.xml?apikey=urkeyhere&zip=27511" > districts_by_zip.xml
        register_uri_with_response('districts.getDistrictsFromZip.xml?apikey=redacted&zip=27511', 'districts_by_zip.xml')
        @districts = Daywalker::District.all_by_zipcode(27511)
      end

      it 'should find NC district 13 and 4' do
        @districts.map{|d| d.state}.should == ['NC', 'NC']
        @districts.map{|d| d.number}.should == [13, 4]
      end
    end

    describe 'bad api key' do
      setup do
        # curl -i "http://services.sunlightlabs.com/api/districts.getDistrictsFromZip.xml?apikey=badkeyhere&zip=27511" > districts_by_zip_bad_api.xml 
        register_uri_with_response 'districts.getDistrictsFromZip.xml?apikey=redacted&zip=27511', 'districts_by_zip_bad_api.xml'
      end

      specify 'should raise BadApiKeyError' do
        lambda {
          Daywalker::District.all_by_zipcode(27511)
        }.should raise_error(Daywalker::BadApiKeyError)
      end
    end

    describe 'missing zip' do
      specify 'should raise ArgumentError for missing zip' do
        lambda {
          Daywalker::District.all_by_zipcode(nil)
        }.should raise_error(ArgumentError, /zip/)
      end
    end
  end

  describe 'unique_by_address' do
    describe 'happy path' do
      before do
        Daywalker.geocoder.stub!(:locate).with("110 8th St., Troy, NY 12180").and_return({:longitude => -73.684236, :latitude => 42.731245})

        Daywalker::District.stub!(:unique_by_latitude_and_longitude).with(42.731245, -73.684236)
      end

      it 'should use unique_by_latitude_and_longitude' do
        Daywalker::District.should_receive(:unique_by_latitude_and_longitude).with(42.731245, -73.684236)

        Daywalker::District.unique_by_address("110 8th St., Troy, NY 12180")
      end

      it 'should use the geocoder to locate a latitude and longitude' do
        Daywalker.geocoder.should_receive(:locate).with("110 8th St., Troy, NY 12180").and_return({:longitude => -73.684236, :latitude => 42.731245})
        Daywalker::District.unique_by_address("110 8th St., Troy, NY 12180")
      end
    end

    describe 'with nil address' do
      it 'should raise ArgumentError if address is not given' do
        lambda {
          Daywalker::District.unique_by_address(nil)
        }.should raise_error(ArgumentError, /address/)
      end
    end
  end

  describe 'legislators' do
    before do
      @district = Daywalker::District.new(:state => 'NY', :number => 21)

      @representative = mock('representative')
      @junior_senator = mock('junior senator')
      @senior_senator = mock('senior senator')

      Daywalker::Legislator.stub!(:unique_by_state_and_district).with('NY', 21).and_return(@representative)
      Daywalker::Legislator.stub!(:unique_by_state_and_district).with('NY', :junior_seat).and_return(@junior_senator)
      Daywalker::Legislator.stub!(:unique_by_state_and_district).with('NY', :senior_seat).and_return(@senior_senator)
    end

    it 'should find the representative for the district' do
      Daywalker::Legislator.should_receive(:unique_by_state_and_district).with('NY', 21).and_return(@representative)
      
      @district.legislators
    end

    it 'should find the junior senator for the state' do
      Daywalker::Legislator.should_receive(:unique_by_state_and_district).with('NY', :junior_seat).and_return(@junior_senator)

      @district.legislators
    end

    it 'should find the senior senator for the state' do
      Daywalker::Legislator.should_receive(:unique_by_state_and_district).with('NY', :senior_seat).and_return(@senior_senator)

      @district.legislators
    end

    it 'should return the representative, junior senator, and senior senator' do
      @district.legislators.should == {
        :representative => @representative,
        :junior_senator => @junior_senator,
        :senior_senator => @senior_senator
      }
    end

    it 'should not not attempt to look up if it has been done already' do
      @district.legislators

      Daywalker::Legislator.should_not_receive(:unique_by_state_and_district).with('NY', :senior_seat).and_return(@senior_senator)
      Daywalker::Legislator.should_not_receive(:unique_by_state_and_district).with('NY', :senior_seat).and_return(@senior_senator)
      Daywalker::Legislator.should_not_receive(:unique_by_state_and_district).with('NY', 21).and_return(@representative)

      @district.legislators
    end

  end
end

