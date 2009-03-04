class Legislator < ActiveRecord::Base
  
  validates_presence_of :bioguide_id, :district, :state, :name
  
  
  
  def self.update
    api_legislators = Daywalker::Legislator.all
    
    api_legislators.each do |api_legislator|
      legislator = Legislator.find_or_initialize_by_bioguide_id api_legislator.bioguide_id
      legislator.attributes = {
        :title => title_for(api_legislator),
        :gender => gender_for(api_legislator),
        :name => name_for(api_legislator),
        :district => district_for(api_legislator),
        :state => api_legislator.state,
        :party => party_for(api_legislator),
        :in_office => api_legislator.in_office
      }
      legislator.save!
    end
    ['SUCCESS', "#{api_legislators.size} legislators created or updated"]
  rescue => e
    ['FAILED', e.message]
  end
  
  # Some Daywalker-specific transformations
  def self.title_for(api_legislator)
    {
      :representative => 'Rep',
      :senator => 'Sen',
      nil => 'Del'
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