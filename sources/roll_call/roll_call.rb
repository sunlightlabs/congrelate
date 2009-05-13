require 'hpricot'

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
        bill_identifier = ? or identifier like ?',
        "#{q}%", "% #{q}%", "%(#{q}%",
        "#{bill_q}", "%#{q}%"
      ]
    }
  }

  def self.sort(fields)
    fields.sort
  end
  
  def self.field_for(legislators, column)
    field = {}
    identifier = column
    
    vote_data = {}
    roll_call = RollCall.find_by_identifier identifier
    roll_call.votes.each {|vote| vote_data[vote.bioguide_id] = vote.position}
    
    legislators.each do |legislator|      
      field[legislator.bioguide_id] = vote_data[legislator.bioguide_id]
    end
    
    field[:header] = roll_call.bill_identifier || "Vote #{roll_call.identifier}"
    field[:title] = roll_call.question
    
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
  
  def self.popup_form?
    true
  end
  
end

get '/roll_call/form' do
  popup_form_for source_for(:roll_call)
end

get '/roll_call/search' do
  if !params[:q].blank?
    # rudimentary pagination
    per_page = 10
    @page = (params[:page] || 1).to_i
    offset = (@page - 1) * per_page
    count = RollCall.search(params[:q]).listing.count
    @is_prev = @page > 1
    @is_next = offset + per_page < count
    @roll_calls = RollCall.search(params[:q]).listing.all(:limit => per_page, :offset => offset)
  end
  
  if @roll_calls and @roll_calls.any?
    erb :"../sources/roll_call/table", :locals => {:roll_calls => @roll_calls, :is_prev => @is_prev, :is_next => @is_next, :page => @page}
  else
    'No results found.'
  end
end