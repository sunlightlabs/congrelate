class Legislator < ActiveRecord::Base
  validates_presence_of :bioguide_id, :district, :state, :name
  named_scope :active, :conditions => {:in_office => true}
  
  def self.fields
    ['name', 'state', 'district', 'gender', 'party']
  end
  
  def self.data_for(legislators, columns)
    data = {}
    
    # only use columns that were checked
    columns.each {|column, use| data[column] = {} if use == '1'}
    
    legislators.each do |legislator|
      data.keys.each do |column|
        data[column][legislator.bioguide_id] = legislator.send(column)
      end
    end
    data
  end
  
  def self.update
    api_legislators = Daywalker::Legislator.all :all_legislators => true
    
    api_legislators.each do |api_legislator|
      legislator = Legislator.find_or_initialize_by_bioguide_id api_legislator.bioguide_id
      legislator.attributes = {
        :title => title_for(api_legislator),
        :gender => gender_for(api_legislator),
        :name => name_for(api_legislator),
        :district => district_for(api_legislator),
        :state => api_legislator.state,
        :party => party_for(api_legislator),
        :in_office => api_legislator.in_office,
        :crp_id => api_legislator.crp_id,
        :govtrack_id => api_legislator.govtrack_id,
        :votesmart_id => api_legislator.votesmart_id,
        :fec_id => api_legislator.fec_id
      }
      legislator.save!
    end
    ['SUCCESS', "#{api_legislators.size} legislators created or updated"]
  rescue => e
    ['FAILED', e.message]
  end
  
  private
  
  # Some Daywalker-specific transformations
  def self.title_for(api_legislator)
    {
      :representative => 'Rep.',
      :senator => 'Sen.',
      nil => 'Del.'
    }[api_legislator.title]
  end
  
  def self.name_for(api_legislator)
    "#{api_legislator.first_name} #{api_legislator.last_name}"
  end
  
  def self.district_for(api_legislator)
    api_legislator.district.to_s.titleize
  end
  
  def self.party_for(api_legislator)
    api_legislator.party.to_s.first.capitalize
  end
  
  def self.gender_for(api_legislator)
    api_legislator.gender.to_s.first.capitalize
  end
end