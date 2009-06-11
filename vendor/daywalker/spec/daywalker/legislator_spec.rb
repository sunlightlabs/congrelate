require File.dirname(__FILE__) + '/../spec_helper'

describe Daywalker::Legislator do

  describe "John Q. Doe Jr." do
    before do
      @legislator = Daywalker::Legislator.new(:first_name => 'John', :middle_name => 'Q.', :last_name => 'Doe', :name_suffix => 'Jr.')
    end

    specify 'should have correct full name' do
      @legislator.full_name.should == 'John Q. Doe Jr.'
    end
  end

  describe 'Jane Doe' do
    before do
      @legislator = Daywalker::Legislator.new(:first_name => 'Jane', :last_name => 'Doe')
    end

    specify 'should have correct full name' do
      @legislator.full_name.should == 'Jane Doe'
    end
  end

  describe 'all_by_zip' do
    describe 'happy path' do
      setup do
        # curl -i "http://services.sunlightlabs.com/api/legislators.allForZip.xml?zip=27511&apikey=redacted" > legislators_by_zip.xml
        register_uri_with_response 'legislators.allForZip.xml?zip=27511&apikey=redacted', 'legislators_by_zip.xml'

        @legislators = Daywalker::Legislator.all_by_zip 27511
      end

      it 'return legislators identified by votersmart ids 119, 21082, 21787, and 10205' do
        @legislators.map{|each| each.votesmart_id}.should == [119, 21082, 21787, 10205]
      end
    end

    describe 'with a bad API key' do
      setup do
        #  curl -i "http://services.sunlightlabs.com/api/legislators.allForZip.xml?zip=27511&apikey=redacted" > legislators_by_zip
        register_uri_with_response 'legislators.allForZip.xml?zip=27511&apikey=redacted', 'legislators_by_zip_bad_api.xml'
      end

      it 'should raise bad API key error' do
        lambda {
          Daywalker::Legislator.all_by_zip 27511
        }.should raise_error(Daywalker::BadApiKeyError) 
      end
    end

    describe 'without a zip code' do
      it 'should raise ArgumentError for missing zip' do
        lambda {
          Daywalker::Legislator.all_by_zip nil
        }.should raise_error(ArgumentError, /zip/) 
      end
    end
  end

  describe 'found with unique' do
    describe 'by state and district, with one result,' do
      describe 'happy path' do
        before do
          register_uri_with_response 'legislators.get.xml?apikey=redacted&state=NY&district=4', 'legislators_find_by_ny_district_4.xml'
          @legislator = Daywalker::Legislator.unique(:state => 'NY', :district => 4)
        end

        it 'should have votesmart id 119' do
          @legislator.votesmart_id.should == 119
        end
      end

      describe 'with bad API key' do
        before do
          register_uri_with_response 'legislators.get.xml?apikey=redacted&state=NY&district=4', 'legislators_find_by_ny_district_4_bad_api.xml'
        end

        it 'should raise a missing parameter error for zip' do
          lambda {
            Daywalker::Legislator.unique(:state => 'NY', :district => 4)
          }.should raise_error(Daywalker::BadApiKeyError) 
        end
      end

      describe 'with multiple results' do
        before do
          register_uri_with_response 'legislators.get.xml?state=NY&title=Sen&apikey=redacted', 'legislators_find_one_by_ny_senators.xml'
        end

        it 'should raise an error about multiple legislators returned' do
          lambda {
            Daywalker::Legislator.unique(:state => 'NY', :title => :senator)
          }.should raise_error(ArgumentError, "The conditions provided returned multiple results, by only one is expected")
        end
      end

      describe 'with no results' do
        before do
          register_uri_with_response 'legislators.get.xml?state=JK&title=Sen&apikey=redacted', 'get_nonexistent_legislator.xml'
        end

        it 'should raise NotFoundError' do
          lambda {
            Daywalker::Legislator.unique(:state => 'JK', :title => :senator)
          }.should raise_error(Daywalker::NotFoundError)
        end
      end
    end
  end

  describe 'found with all' do
    describe 'by state and title, with multiple results' do
      describe 'happy path' do
        before do
          # curl -i "http://services.sunlightlabs.com/api/legislators.getList.xml?state=NY&title=Sen&apikey=redacted" > legislators_find_ny_senators.xml
          register_uri_with_response 'legislators.getList.xml?state=NY&apikey=redacted&title=Sen', 'legislators_find_ny_senators.xml'
          @legislators = Daywalker::Legislator.all(:state => 'NY', :title => :senator)
        end

        it 'should return legislators with votesmart ids 55463 and 26976' do
          @legislators.map{|each| each.votesmart_id}.should == [55463, 26976]
        end
      end

      describe 'with bad API key' do
        before do
          register_uri_with_response 'legislators.getList.xml?state=NY&apikey=redacted&title=Sen', 'legislators_find_ny_senators_bad_api.xml'
        end

        it 'should raise BadApiKeyError' do
          lambda {
            Daywalker::Legislator.all(:state => 'NY', :title => :senator)
          }.should raise_error(Daywalker::BadApiKeyError)
        end
      end
    end

    describe 'without any conditions' do
      before do
        register_uri_with_response 'legislators.getList.xml?apikey=redacted', 'legislators_all.xml'
      end

      it 'should work' do
        @legislators = Daywalker::Legislator.all
      end
    end
  end

  # TODO switch this to mocking
  describe 'dynamic finder all_by_state_and_title' do
    before do
      register_uri_with_response 'legislators.getList.xml?state=NY&apikey=redacted&title=Sen', 'legislators_find_ny_senators.xml'

      @legislators = Daywalker::Legislator.all_by_state_and_title('NY', :senator)
    end
    
    it 'should return legislators with votesmart ids 55463 and 26976' do
      @legislators.map{|each| each.votesmart_id}.should == [55463, 26976]
    end
    
    it 'should respond to find_all_by_state_and_title' do
      Daywalker::Legislator.should respond_to(:all_by_state_and_title)
    end
  end

  describe 'all_by_latitude_and_longitude' do
    before do
      @district = mock('district', :state => 'NY', :number => 21)
      Daywalker::District.stub!(:unique_by_latitude_and_longitude).with(42.731245, -73.684236).and_return(@district)
      

      @representative = mock('representative')
      @junior_senator = mock('junior senator')
      @senior_senator = mock('senior senator')

      @district.stub!(:legislators).and_return({
        :representative => @representative,
        :junior_senator => @junior_senator,
        :senior_senator => @senior_senator
      })
    end

    it 'should find district by lat & lng' do
      Daywalker::District.should_receive(:unique_by_latitude_and_longitude).with(42.731245, -73.684236).and_return(@district)

      Daywalker::Legislator.all_by_latitude_and_longitude(42.731245, -73.684236)
    end

    it 'should find the legislators for the district' do
      @district.should_receive(:legislators)

      Daywalker::Legislator.all_by_latitude_and_longitude(42.731245, -73.684236)
    end

    it 'should return the representative, junior senator, and senior senator' do
      Daywalker::Legislator.all_by_latitude_and_longitude(42.731245, -73.684236).should == {
        :representative => @representative,
        :junior_senator => @junior_senator,
        :senior_senator => @senior_senator
      }
    end
  end

  describe 'all_by_address' do
    before do
      Daywalker.geocoder.stub!(:locate).with("110 8th St., Troy, NY 12180").and_return({:longitude => -73.684236, :latitude => 42.731245})

      Daywalker::Legislator.stub!(:all_by_latitude_and_longitude).with(42.731245, -73.684236)
    end

    it 'should geocode the address' do
      Daywalker.geocoder.should_receive(:locate).with("110 8th St., Troy, NY 12180").and_return({:longitude => -73.684236, :latitude => 42.731245})

      Daywalker::Legislator.all_by_address("110 8th St., Troy, NY 12180")
    end

    it 'should find legislators by latitude and longitude' do
      Daywalker::Legislator.should_receive(:all_by_latitude_and_longitude).with(42.731245, -73.684236)

      Daywalker::Legislator.all_by_address("110 8th St., Troy, NY 12180")
    end

  end

  describe 'representative parsed from XML' do
    setup do
      @xml = <<-XML
        <legislator>
          <district>4</district>
          <title>Rep</title>
          <eventful_id>P0-001-000016562-5</eventful_id>
          <in_office>1</in_office>
          <state>NC</state>
          <votesmart_id>119</votesmart_id>
          <official_rss></official_rss>
          <party>D</party>
          <email></email>
          <crp_id>N00002260</crp_id>
          <website>http://price.house.gov/</website>
          <fax>202-225-2014</fax>
          <govtrack_id>400326</govtrack_id>
          <firstname>David</firstname>
          <middlename></middlename>
          <lastname>Price</lastname>
          <congress_office>2162 Rayburn House Office Building</congress_office>
          <bioguide_id>P000523</bioguide_id>
          <webform>http://price.house.gov/contact/contact_form.shtml</webform>
          <youtube_url>http://www.youtube.com/repdavidprice</youtube_url>
          <nickname></nickname>
          <phone>202-225-1784</phone>
          <fec_id>H6NC04037</fec_id>
          <gender>M</gender>
          <name_suffix></name_suffix>
          <twitter_id></twitter_id>
          <sunlight_old_id>fakeopenID319</sunlight_old_id>
          <congresspedia_url>http://www.sourcewatch.org/index.php?title=David_Price</congresspedia_url>
        </legislator>
      XML
    end

    subject { Daywalker::Legislator.parse(@xml) }

    specify_its_attributes  :district => 4,
                            :title => :representative,
                            :eventful_id => 'P0-001-000016562-5',
                            :in_office => true,
                            :state => 'NC',
                            :votesmart_id => 119,
                            :official_rss_url => nil,
                            :party => :democrat,
                            :email => nil,
                            :crp_id => 'N00002260',
                            :website_url => 'http://price.house.gov/',
                            :fax_number => '202-225-2014',
                            :govtrack_id => 400326,
                            :first_name => 'David',
                            :middle_name => nil,
                            :last_name => 'Price',
                            :congress_office => '2162 Rayburn House Office Building',
                            :bioguide_id => 'P000523',
                            :webform_url => 'http://price.house.gov/contact/contact_form.shtml',
                            :youtube_url => 'http://www.youtube.com/repdavidprice',
                            :nickname => nil,
                            :phone => '202-225-1784',
                            :fec_id => 'H6NC04037',
                            :gender => :male,
                            :name_suffix => nil,
                            :twitter_id => nil,
                            :sunlight_old_id => 'fakeopenID319',
                            :congresspedia_url => 'http://www.sourcewatch.org/index.php?title=David_Price'
  end

  describe 'senior senator parsed from XML' do
    before do
      @xml = <<-XML
        <legislator>
          <district>Senior Seat</district>
          <title>Sen</title>
          <eventful_id>P0-001-000016060-2</eventful_id>
          <in_office>1</in_office>
          <state>NC</state>
          <votesmart_id>41533</votesmart_id>
          <party>R</party>
          <email/>
          <crp_id>N00008071</crp_id>
          <website>http://dole.senate.gov</website>
          <fax>202-224-1100</fax>
          <govtrack_id>300035</govtrack_id>
          <firstname>Elizabeth</firstname>
          <middlename>H.</middlename>
          <lastname>Dole</lastname>
          <congress_office>555 Dirksen Office Building</congress_office>
          <bioguide_id>D000601</bioguide_id>
          <webform>http://dole.senate.gov/public/index.cfm?FuseAction=ContactInformation.ContactForm</webform>
          <nickname/>
          <phone>202-224-6342</phone>
          <fec_id>S2NC00083</fec_id>
          <gender>F</gender>
          <name_suffix/>
          <twitter_id/>
          <sunlight_old_id>fakeopenID468</sunlight_old_id>
          <congresspedia_url>http://www.sourcewatch.org/index.php?title=Elizabeth_Dole</congresspedia_url>
        </legislator>
      XML
    end

    subject { Daywalker::Legislator.parse(@xml) }

    specify_its_attributes  :district => :senior_seat,
                            :title => :senator,
                            :eventful_id => 'P0-001-000016060-2',
                            :in_office => true,
                            :state => 'NC',
                            :votesmart_id => 41533,
                            :party => :republican,
                            :email => nil,
                            :crp_id => 'N00008071',
                            :website_url => 'http://dole.senate.gov',
                            :fax_number => '202-224-1100',
                            :govtrack_id => 300035,
                            :first_name => 'Elizabeth',
                            :middle_name => 'H.',
                            :last_name => 'Dole',
                            :congress_office => '555 Dirksen Office Building',
                            :bioguide_id => 'D000601',
                            :webform_url => 'http://dole.senate.gov/public/index.cfm?FuseAction=ContactInformation.ContactForm',
                            :nickname => nil,
                            :phone => '202-224-6342',
                            :fec_id => 'S2NC00083',
                            :gender => :female,
                            :name_suffix => nil,
                            :twitter_id => nil,
                            :sunlight_old_id => 'fakeopenID468',
                            :congresspedia_url => 'http://www.sourcewatch.org/index.php?title=Elizabeth_Dole'
  end

  describe 'junior senator parsed from XML' do
    before do
      @xml = <<-XML
        <legislator>
          <district>Junior Seat</district>
          <title>Sen</title>
          <eventful_id>P0-001-000016040-8</eventful_id>
          <in_office>1</in_office>
          <state>NC</state>
          <votesmart_id>21787</votesmart_id>
          <party>R</party>
          <email/>
          <crp_id>N00002221</crp_id>
          <website>http://burr.senate.gov/</website>
          <fax>202-228-2981</fax>
          <govtrack_id>400054</govtrack_id>
          <firstname>Richard</firstname>
          <middlename>M.</middlename>
          <lastname>Burr</lastname>
          <congress_office>217 Russell Senate Office Building</congress_office>
          <bioguide_id>B001135</bioguide_id>
          <webform>http://burr.senate.gov/public/index.cfm?FuseAction=Contact.Home</webform>
          <nickname/>
          <phone>202-224-3154</phone>
          <fec_id>S4NC00089</fec_id>
          <gender>M</gender>
          <name_suffix/>
          <twitter_id/>
          <sunlight_old_id>fakeopenID449</sunlight_old_id>
          <congresspedia_url>http://www.sourcewatch.org/index.php?title=Richard_Burr</congresspedia_url>
        </legislator>
      XML
    end

    subject { Daywalker::Legislator.parse(@xml) }

    specify_its_attributes :district => :junior_seat,
                           :title => :senator,
                           :eventful_id => 'P0-001-000016040-8',
                           :in_office => true,
                           :state => 'NC',
                           :votesmart_id => 21787,
                           :party => :republican,
                           :email => nil,
                           :crp_id => 'N00002221',
                           :website_url => 'http://burr.senate.gov/',
                           :fax_number => '202-228-2981',
                           :govtrack_id => 400054,
                           :first_name => 'Richard',
                           :middle_name => 'M.',
                           :last_name => 'Burr',
                           :congress_office => '217 Russell Senate Office Building',
                           :bioguide_id => 'B001135',
                           :webform_url => 'http://burr.senate.gov/public/index.cfm?FuseAction=Contact.Home',
                           :nickname => nil,
                           :phone => '202-224-3154',
                           :fec_id => 'S4NC00089',
                           :gender => :male,
                           :name_suffix => nil,
                           :twitter_id => nil,
                           :sunlight_old_id => 'fakeopenID449',
                           :congresspedia_url => 'http://www.sourcewatch.org/index.php?title=Richard_Burr'
  end


end
