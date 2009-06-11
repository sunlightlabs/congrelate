require File.dirname(__FILE__) + '/../spec_helper'

describe Daywalker::TypeConverter do
  describe 'gender_letter_to_sym' do
    it 'should convert F to :female' do
      Daywalker::TypeConverter.gender_letter_to_sym('F').should == :female
    end

    it 'should convert M to :male' do
      Daywalker::TypeConverter.gender_letter_to_sym('M').should == :male
    end

    it 'should raise ArgumentError for unknown genders' do
      lambda {
        Daywalker::TypeConverter.gender_letter_to_sym('aiee')
      }.should raise_error(ArgumentError)
    end
  end

  describe 'party_letter_to_sym' do
    it 'should convert D to :democrat' do
      Daywalker::TypeConverter.party_letter_to_sym('D').should == :democrat
    end

    it 'should convert R to democrat' do
      Daywalker::TypeConverter.party_letter_to_sym('R').should == :republican
    end

    it 'should convert I to independent' do
      Daywalker::TypeConverter.party_letter_to_sym('I').should == :independent
    end

    it 'should raise ArgumentError for unknown parties' do
      lambda {
        Daywalker::TypeConverter.party_letter_to_sym('zomg')
      }.should raise_error(ArgumentError)
    end
  end

  describe 'title_abbr_to_sym' do
    it 'should convert Sen to :senator' do
      Daywalker::TypeConverter.title_abbr_to_sym('Sen').should == :senator
    end

    it 'should convert Rep to :representative' do
      Daywalker::TypeConverter.title_abbr_to_sym('Rep').should == :representative
    end

    it 'should raise ArgumentError for unknown titles' do
      lambda {
        Daywalker::TypeConverter.title_abbr_to_sym('zomg')
      }.should raise_error(ArgumentError)
    end
  end

  describe 'district_to_sym_or_i' do
    it 'should convert 5 to 5' do
      Daywalker::TypeConverter.district_to_sym_or_i('5').should == 5
    end

    it 'should convert Junior Seat to :junior_seat' do
      Daywalker::TypeConverter.district_to_sym_or_i('Junior Seat').should == :junior_seat
    end

    it 'should convert Senior Seat to :senior_seat' do
      Daywalker::TypeConverter.district_to_sym_or_i('Senior Seat').should == :senior_seat
    end

    it 'should raise ArgumentError for bad input' do
      lambda {
        Daywalker::TypeConverter.district_to_sym_or_i('zomg')
      }.should raise_error(ArgumentError)
    end
  end

  describe 'sym_or_i_to_district' do
    it 'should convert :junior_seat to Junior Seat' do
      Daywalker::TypeConverter.sym_or_i_to_district(:junior_seat).should == 'Junior Seat'
    end

    it 'should convert :senior_seat to Senior Seat' do
      Daywalker::TypeConverter.sym_or_i_to_district(:senior_seat).should == 'Senior Seat'
    end

    it 'should convert 5 to 5' do
      Daywalker::TypeConverter.sym_or_i_to_district(5).should == '5'
    end

    it 'should raise ArgumentError for everything else' do
      lambda {
        Daywalker::TypeConverter.sym_or_i_to_district(:zomg)
      }.should raise_error(ArgumentError)
    end
  end

  describe 'sym_to_title_abbr' do
    it 'should convert :senator to Sen' do
      Daywalker::TypeConverter.sym_to_title_abbr(:senator).should == 'Sen'
    end

    it 'should convert :representative to Rep' do
      Daywalker::TypeConverter.sym_to_title_abbr(:representative).should == 'Rep'
    end

    it 'should raise ArgumentError for unknown titles' do
      lambda {
        Daywalker::TypeConverter.sym_to_title_abbr(:zomg)
      }.should raise_error(ArgumentError)
    end
  end

  describe 'sym_to_party_letter' do
    it 'should convert :democrat to D' do
      Daywalker::TypeConverter.sym_to_party_letter(:democrat).should == 'D'
    end

    it 'should convert :republican to R' do
      Daywalker::TypeConverter.sym_to_party_letter(:republican).should == 'R'
    end

    it 'should convert :independent to I' do
      Daywalker::TypeConverter.sym_to_party_letter(:independent).should == 'I'
    end

    it 'should raise ArgumentError for unknown parties' do
      lambda {
        Daywalker::TypeConverter.sym_to_party_letter(:zomg)
      }.should raise_error(ArgumentError)
    end
  end

  describe 'sym_to_gender_letter' do
    it 'should convert :male to M' do
      Daywalker::TypeConverter.sym_to_gender_letter(:male).should == 'M'
    end

    it 'should convert :female to F' do
      Daywalker::TypeConverter.sym_to_gender_letter(:female).should == 'F'
    end

    it 'should raise ArgumentError for unknown genders' do
      lambda {
        Daywalker::TypeConverter.sym_to_gender_letter(:zomg)
      }.should raise_error(ArgumentError)
    end
  end

  describe 'blank_to_nil' do
    it 'should convert "" to nil' do
      Daywalker::TypeConverter.blank_to_nil('').should be_nil
    end

    it 'should leave "zomg" alone' do
      Daywalker::TypeConverter.blank_to_nil('zomg').should == 'zomg'
    end
  end

  describe 'normalize_conditions' do
    before do
      @conditions = {
        :title => :senator,
        :district => 5,
        :official_rss_url => 'http://zomg.com/index.rss',
        :party => :democrat,
        :website_url => 'http://zomg.com',
        :fax_number => '1800vote4me',
        :first_name => 'John',
        :middle_name => 'Q',
        :last_name => 'Doe',
        :webform_url => 'http://zomg.com/contact',
        :gender => :male
      }
    end

    it 'should convert district value' do
      Daywalker::TypeConverter.should_receive(:sym_or_i_to_district).with(5)
      Daywalker::TypeConverter.normalize_conditions(@conditions)
    end
    it 'should convert title value' do
      Daywalker::TypeConverter.should_receive(:sym_to_title_abbr).with(:senator)
      Daywalker::TypeConverter.normalize_conditions(@conditions)
    end

    it 'should copy official_rss_url value to official_rss' do
      Daywalker::TypeConverter.normalize_conditions(@conditions)[:official_rss].should == 'http://zomg.com/index.rss'
    end

    it 'should remove official_rss_url value' do
      Daywalker::TypeConverter.normalize_conditions(@conditions).should_not have_key(:official_rss_url)
    end

    it 'should convert party value' do
      Daywalker::TypeConverter.should_receive(:sym_to_party_letter).with(:democrat)
      Daywalker::TypeConverter.normalize_conditions(@conditions)
    end

    it 'should copy website_url value to website' do
      Daywalker::TypeConverter.normalize_conditions(@conditions)[:website].should == 'http://zomg.com'
    end

    it 'should remove website_url value' do
      Daywalker::TypeConverter.normalize_conditions(@conditions).should_not have_key(:website_url)
    end

    it 'should copy fax_number value to fax' do
      Daywalker::TypeConverter.normalize_conditions(@conditions)[:fax].should == '1800vote4me'
    end

    it 'should remove fax_number value' do
      Daywalker::TypeConverter.normalize_conditions(@conditions).should_not have_key(:fax_number)
    end

    it 'should copy first_name value to firstname' do
      Daywalker::TypeConverter.normalize_conditions(@conditions)[:firstname].should == 'John'
    end

    it 'should remove first_name value' do
      Daywalker::TypeConverter.normalize_conditions(@conditions).should_not have_key(:first_name)
    end

    it 'should copy middle_name value to middlename' do
      Daywalker::TypeConverter.normalize_conditions(@conditions)[:middlename].should == 'Q'
    end

    it 'should remove middle_name value' do
      Daywalker::TypeConverter.normalize_conditions(@conditions).should_not have_key(:middle_name)
    end

    it 'should copy last_name value to lastname' do
      Daywalker::TypeConverter.normalize_conditions(@conditions)[:lastname].should == 'Doe'
    end

    it 'should remove last_name value' do
      Daywalker::TypeConverter.normalize_conditions(@conditions).should_not have_key(:last_name)
    end

    it 'should copy webform_url value to webform' do
      Daywalker::TypeConverter.normalize_conditions(@conditions)[:webform].should == 'http://zomg.com/contact'
    end

    it 'should remove webform_url value' do
      Daywalker::TypeConverter.normalize_conditions(@conditions).should_not have_key(:webform_url)
    end

    it 'should convert gender value' do
      Daywalker::TypeConverter.should_receive(:sym_to_gender_letter).with(:male)
      Daywalker::TypeConverter.normalize_conditions(@conditions)
    end
  end

end
