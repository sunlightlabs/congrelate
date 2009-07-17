require 'daywalker'
require 'open-uri'
require 'json'

class Legislator < ActiveRecord::Base
  has_many :committees, :through => :committee_memberships
  has_many :committee_memberships
  has_many :parent_committees, :through => :committee_memberships, :source => :committee, :conditions => 'parent_id IS NULL'
  has_many :subcommittees, :through => :committee_memberships, :source => :committee, :conditions => 'parent_id IS NOT NULL'
  
  validates_presence_of :bioguide_id, :district, :state, :name
  
  named_scope :active, :conditions => {:in_office => true}
  named_scope :filter, lambda {|conditions|
    conditions.delete('house') unless ['house', 'senate'].include?(conditions[:house])
    {:conditions => conditions}
  }
  
  def self.sort(fields)
    cols = ['name', 'state', 'district', 'gender', 'party', 'committees', 'subcommittees']
    fields.sort {|a, b| cols.index(a) <=> cols.index(b)}
  end
  
  def self.field_for(legislators, column)
    field = {}
    legislators.each do |legislator|
      field[legislator.bioguide_id] = case column
      when 'committees', 'subcommittees'
        committees = column == 'committees' ? legislator.parent_committees : legislator.subcommittees
        {
          :html => 
            committees.map {|committee| 
              %Q{<a href="#" class="filter" title="Filter by #{committee.short_name}">#{committee.short_name}</a>}
            }.join(', '),
          :data => committees.map(&:name).join(', ')
        }
      when 'district'
        {
          :data => legislator.district,
          :searchable => legislator.house
        }
      when 'state'
        {
          :data => legislator.state,
          :searchable => state_name(legislator.state)
        }
      when 'party'
        {
          :data => legislator.party[0...1],
          :searchable => legislator.party
        }
      else
        legislator.send column
      end
    end
    field
  end
  
  def self.update
    Daywalker.api_key = api_key
    api_legislators = Daywalker::Legislator.all
    
    created_count = 0
    updated_count = 0
    
    mistakes = []
    
    api_legislators.each do |api_legislator|
      legislator = Legislator.find_or_initialize_by_bioguide_id api_legislator.bioguide_id
      
      if legislator.new_record?
        created_count += 1
        puts "[Legislator #{legislator.bioguide_id}] Created"
      else
        updated_count += 1
        puts "[Legislator #{legislator.bioguide_id}] Updated"
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
      
      begin
        open "http://services.sunlightlabs.com/api/committees.allForLegislator?apikey=#{api_key}&bioguide_id=#{legislator.bioguide_id}" do |response|
          committees = JSON.parse(response.read)
          committees['response']['committees'].each do |comm|
            committee = Committee.find_or_initialize_by_keyword comm['committee']['id']
            committee.attributes = {:chamber => comm['committee']['chamber'], :name => comm['committee']['name']}
            puts "  [Committee #{committee.new_record? ? 'Created' : 'Updated'}] #{committee.name}"
            committee.save!
            
            unless membership = legislator.committee_memberships.find_by_committee_id(committee.id)
              membership = legislator.committee_memberships.build :committee_id => committee.id
              puts "    - Added Membership"
            end
            
            if comm['committee']['subcommittees']
              comm['committee']['subcommittees'].each do |subcomm|
                subcommittee = Committee.find_or_initialize_by_keyword subcomm['committee']['id']
                subcommittee.attributes = {:chamber => subcomm['committee']['chamber'], :name => subcomm['committee']['name'], :parent_id => committee.id}
                puts "    [Subcommittee #{subcommittee.new_record? ? 'Created' : 'Updated'}] #{subcommittee.name}"
                subcommittee.save!
                
                unless membership = legislator.committee_memberships.find_by_committee_id(subcommittee.id)
                  membership = legislator.committee_memberships.build :committee_id => subcommittee.id
                  puts "      - Added Membership"
                end
              end
            end
          end
          
        end
      rescue OpenURI::HTTPError => e
        mistakes << "Error getting committees for legislator #{legislator.bioguide_id}"
      end
      
      legislator.save!
    end
    
    success_msg = "#{created_count} legislators created, #{updated_count} updated"
    success_msg << "\n" + mistakes.join("\n") if mistakes.any?
    ['SUCCESS', success_msg]
  rescue => e
    ['FAILED', e.inspect]
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
    api_legislator.party.to_s.capitalize
  end
  
  def self.gender_for(api_legislator)
    api_legislator.gender.to_s.first.capitalize
  end
  
  def self.state_name(state)
    {
      "AL" => "Alabama",
      "AK" => "Alaska",
      "AZ" => "Arizona",
      "AR" => "Arkansas",
      "CA" => "California",
      "CO" => "Colorado",
      "CT" => "Connecticut",
      "DE" => "Delaware",
      "DC" => "District of Columbia",
      "FL" => "Florida",
      "GA" => "Georgia",
      "HI" => "Hawaii",
      "ID" => "Idaho",
      "IL" => "Illinois",
      "IN" => "Indiana",
      "IA" => "Iowa",
      "KS" => "Kansas",
      "KY" => "Kentucky",
      "LA" => "Louisiana",
      "ME" => "Maine",
      "MD" => "Maryland",
      "MA" => "Massachusetts",
      "MI" => "Michigan",
      "MN" => "Minnesota",
      "MS" => "Mississippi",
      "MO" => "Missouri",
      "MT" => "Montana",
      "NE" => "Nebraska",
      "NV" => "Nevada",
      "NH" => "New Hampshire",
      "NJ" => "New Jersey",
      "NM" => "New Mexico",
      "NY" => "New York",
      "NC" => "North Carolina",
      "ND" => "North Dakota",
      "OH" => "Ohio",
      "OK" => "Oklahoma",
      "OR" => "Oregon",
      "PA" => "Pennsylvania",
      "PR" => "Puerto Rico",
      "RI" => "Rhode Island",
      "SC" => "South Carolina",
      "SD" => "South Dakota",
      "TN" => "Tennessee",
      "TX" => "Texas",
      "UT" => "Utah",
      "VT" => "Vermont",
      "VA" => "Virginia",
      "WA" => "Washington",
      "WV" => "West Virginia",
      "WI" => "Wisconsin",
      "WY" => "Wyoming"
    }[state.to_s.upcase]
  end
end

class Committee < ActiveRecord::Base
  has_many :legislators, :through => :committee_memberships
  has_many :committee_memberships
  
  has_many :subcommittees, :class_name => 'Committee', :foreign_key => :parent_id
  belongs_to :parent_committee, :class_name => 'Committee', :foreign_key => :parent_id
  
  def short_name
    name.sub /^[\w\s]+ommm?ittee on (the )?/, ''
  end
end

class CommitteeMembership < ActiveRecord::Base
  belongs_to :committee
  belongs_to :legislator
end