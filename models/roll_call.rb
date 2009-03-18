class RollCall < ActiveRecord::Base 

  has_many :votes, :dependent => :delete_all
  validates_associated :votes
  validates_presence_of :question, :result, :identifier
  
  named_scope :bills, :conditions => 'bill_identifier is not null'
  
  named_scope :listing, :order => 'held_at desc'
  named_scope :search, lambda { |q|
    # for bill searching, support "H.R. 267", "HR 267", etc.
    bill_q = q.gsub(/[^\w\d]/, '')
    {:conditions => [
        'question like ? or question like ? or question like ? or
        bill_identifier like ? or bill_identifier like ? or
        identifier like ?',
        "#{q}%", "% #{q}%", "%(#{q}%",
        "#{bill_q}%", "% #{bill_q}%",
        "%#{q}%"
      ]
    }
  }

  def self.sort(fields)
    fields.sort
  end
  
  def self.data_for(legislators, columns)
    data = {}
    # only use columns that were checked
    columns.each {|column, use| data[column] = {} if use == '1'}
    
    data.keys.each do |roll_call_identifier|
      vote_data = {}
      votes = Vote.all :conditions => {:roll_call_identifier => roll_call_identifier}
      votes.each {|vote| vote_data[vote.bioguide_id] = vote.position}
      
      legislators.each do |legislator|
        data[roll_call_identifier][legislator.bioguide_id] = vote_data[legislator.bioguide_id]
      end
    end
    data
  end
  
  def self.update(options = {})
    congress = options[:congress] || self.current_congress
    
    FileUtils.mkdir_p "data/govtrack/#{congress}"
    
    if system("rsync -az govtrack.us::govtrackdata/us/#{congress}/rolls data/govtrack/#{congress}")
      roll_call_count = 0
      missing_bioguides = []
      
      # one hash to associate govtrack to bioguide ids
      legislators = {}
      ActiveRecord::Base.connection.execute("select legislators.govtrack_id, legislators.bioguide_id from legislators").each_hash do |row|
        legislators[row['govtrack_id']] = row['bioguide_id']
      end
      
      Dir.glob("data/govtrack/#{congress}/rolls/*.xml").each do |filename|
        identifier = File.basename filename, '.xml'
        
        # For now, never update an existing roll call or associated vote data
        # Later, use the updated timestamp to know whether the object should be updated
        next if RollCall.find_by_identifier(identifier)

        roll_call = RollCall.new :identifier => identifier
        doc = open(filename) {|f| Hpricot f}
        
        # basic fields
        roll_call.held_at = Time.at(doc.at(:roll)[:when].to_i)
        roll_call.congress = doc.at(:roll)[:session].to_i
        roll_call.roll_call_type = doc.at(:type).inner_text
        roll_call.question = doc.at(:question).inner_text
        roll_call.result = doc.at(:result).inner_text
        
        # associated bill identifier, if any
        if bill = doc.at(:bill)
          roll_call.bill_identifier = bill_id_for bill[:type], bill[:number]
        end
        
        puts "\n[#{identifier}] #{roll_call.question}"
        
        # vote data
        (doc/:voter).each do |elem|
          
          # skip cases
          if elem[:id] == '0'
            next
          end
          
          if legislators[elem[:id]].nil?
            missing_bioguides << elem[:id]
            next
          end
          
          vote = roll_call.votes.build(
            :position => elem[:value],
            :bioguide_id => legislators[elem[:id]],
            :govtrack_id => elem[:id],
            :roll_call_identifier => identifier
          )
        end
        
        roll_call.save!
        roll_call_count += 1
      end
      
      success_msg = "#{roll_call_count} RollCalls created"
      if missing_bioguides.any?
        success_msg << "\nMissing bioguide_id for govtrack_id's: #{missing_bioguides.uniq.join(", ")}" 
      end
      
      ['SUCCESS', success_msg]
    else
      ['FAILED', "Couldn't rsync files for Congress ##{congress} from GovTrack"]
    end
  rescue ActiveRecord::RecordInvalid => e
    roll_call = e.record
    votes = roll_call.votes.select {|v| v.errors.any?}
    if votes.any?
      ['FAILED', votes.first.errors]
    else
      ['FAILED', roll_call.errors]
    end
  rescue => e
    ['FAILED', "#{e.class}: #{e.message}"]
  end
  
  private
  
  # Will return the # of the current congress (2007-2008 is 110th, 2009-2010 is 111th, etc.)
  # Simplistic, should change later
  def self.current_congress
    ((Time.now.year + 1) / 2) - 894
  end
  
  def self.bill_id_for(type, number)
    type_map = {
      :h => 'HR',
      :hr => 'HRES',
      :hj => 'HJRES',
      :sj => 'SJRES',
      :hc => 'HCRES',
      :s => 'S'
    }
    type = type_map[type.downcase.to_sym] || 'X'
    "#{type.upcase}#{number}"
  end
  
end

# Autocomplete route

get '/roll_calls' do
  if params[:q]
    roll_calls = RollCall.search(params[:q]).listing.all(:limit => (params[:limit] || 50))
    roll_calls.map do |roll_call| 
      [roll_call.question, roll_call.identifier, roll_call.held_at.strftime("%b %d, %Y"), roll_call.bill_identifier].join '|'
    end.join "\n"
  else
    status 404
    "Supply a search parameter."
  end
end