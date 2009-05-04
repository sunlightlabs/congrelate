class Legislator < ActiveRecord::Base
  validates_presence_of :bioguide_id, :district, :state, :name
  
  named_scope :active, :conditions => {:in_office => true}
  named_scope :filter, lambda {|conditions|
    conditions.delete('house') unless ['house', 'senate'].include?(conditions[:house])
    {:conditions => conditions}
  }
  
  def self.sort(fields)
    cols = ['name', 'state', 'district', 'gender', 'party']
    fields.sort {|a, b| cols.index(a) <=> cols.index(b)}
  end
  
  def self.field_for(legislators, column)
    field = {}
    legislators.each do |legislator|
      field[legislator.bioguide_id] = legislator.send(column)
    end
    field
  end
  
  def self.data_for(legislators, columns)
    data = {}
    columns.each {|column, use| data[column] = {} if use == '1'}
    data.keys.each do |column|
      data[column] = field_for legislators, column
    end
    data
  end
  
  def self.update
    Daywalker.api_key = api_key
    api_legislators = Daywalker::Legislator.all :all_legislators => true
    
    created_count = 0
    updated_count = 0
    
    api_legislators.each do |api_legislator|
      legislator = Legislator.find_or_initialize_by_bioguide_id api_legislator.bioguide_id
      if legislator.new_record?
        created_count += 1
        puts "[#{api_legislator.bioguide_id}] Created"
      else
        updated_count += 1
        puts "[#{api_legislator.bioguide_id}] Updated"
      end
      
      legislator.attributes = {
        :house => house_for(api_legislator),
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
    ['SUCCESS', "#{created_count} legislators created, #{updated_count} updated"]
  rescue => e
    ['FAILED', e.message]
  end
  
  private
  
  # Some Daywalker-specific transformations
  def self.house_for(api_legislator)
    {
      :representative => 'house',
      :senator => 'senate',
      nil => 'house'
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