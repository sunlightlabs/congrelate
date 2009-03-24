class Contribution < ActiveRecord::Base

  validates_presence_of :cycle, :crp_id, :bioguide_id, :industry

  named_scope :cycle, lambda {|cycle|
    {:conditions => {:cycle => cycle}}
  }
  named_scope :industries, lambda {|industry|
    if !industry.blank? and industry != "*"
      {:select => 'distinct industry', :order => 'industry asc', :conditions => ['industry like ?', "%#{industry}%"]}
    else
      {:select => 'distinct industry', :order => 'industry asc'}
    end
  }

  def self.sort(fields)
    fields
  end
  
  def self.data_for(legislators, columns)
    
  end
  
  def self.update(options = {})
    cycle = options[:cycle] || latest_cycle
    limit = options[:limit] || 150
    
    secrets = OpenSecrets.new :api_key => OPENSECRETS_API_KEY, :cycle => cycle
    
    create_count = 0
    contribution_count = 0
    
    candidates = []
    mistakes = []
    
    # update the candidates table with any new legislator info
    #TODO: Improve the performance here, one single query
    Legislator.active.each do |legislator|
      candidate = Candidate.find_or_initialize_by_bioguide_id_and_crp_id_and_cycle(legislator.bioguide_id, legislator.crp_id, latest_cycle)
      
      if candidate.new_record?
        # log any mistakes
        if candidate.valid?
          # toss any new legislators in the queue to get updated, up to the limit
          candidates << candidate if candidates.size < limit
          
          candidate.save!
          create_count += 1 
        else
          mistakes << "Invalid candidate, Bioguide #{legislator.bioguide_id}, errors:\n\t #{candidate.errors.full_messages.join("\n\t")}"
        end
      end
    end
    
    # any remaining slots should be filled in by the least recently updated legislators
    remaining = limit - candidates.size
    if remaining > 0
      candidates += Candidate.all :order => 'updated_at asc', :limit => remaining
    end
    
    # if there are few enough legislators, there may be duplicates from that process
    candidates = candidates.uniq
    
    
    candidate_count = 0
    # for each candidate, find or create the contribution row for each industry
    candidates.each do |candidate|
      industries = secrets.industries candidate.crp_id
      if industries.is_a? String
        mistakes << "Couldn't get industries for bioguide #{candidate.bioguide_id}, message: #{industries}"
      else
        puts "[#{candidate.bioguide_id}] Scanning top industries..."
        industries['response']['industries']['industry'].each do |industry|
          name = industry['industry_name']
          amount = industry['total']
          contribution = Contribution.find_or_initialize_by_industry_and_cycle_and_bioguide_id name, cycle, candidate.bioguide_id
          contribution.crp_id = candidate.crp_id
          contribution.amount = amount
          contribution.save!
          
          puts "\t#{name}: #{amount}"
          
          contribution_count += 1
        end
        
        # update updated_at
        candidate.update_attribute :updated_at, Time.now
        candidate_count += 1
      end
    end
    
    puts "\n#{mistakes.join("\n")}" if mistakes.any?
    
    ['SUCCESS', "Success, created #{create_count} new candidate rows, updated #{candidate_count} candidates with #{contribution_count} rows of industry contributions"]
  rescue => e
    ['FAILED', "#{e.class}: #{e.message}"]
  end
  
  private
  
  # 2008 => 2008, 2009 => 2008, 2010 => 2010
  # This relies on truncating integers
  def self.latest_cycle
    Time.now.year / 2 * 2
  end

end

class OpenSecrets
  include HTTParty
  base_uri 'http://www.opensecrets.org/api'
  attr_accessor :api_key, :cycle
  
  def initialize(options = {})
    self.api_key = options[:api_key]
    self.cycle = options[:cycle]
  end
  
  def industries(crp_id, url_options = {})
    self.class.get '/', :query => url_options.merge(:method => 'candIndustry', :cid => crp_id, :apikey => api_key, :cycle => cycle)
  end
  
end

get '/industries' do
  if params[:q]
    Contribution.cycle(2008).industries(params[:q]).map(&:industry).join "\n"
  else
    status 404
    "Supply a search parameter."
  end
end