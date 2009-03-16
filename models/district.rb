class District < ActiveRecord::Base

  def self.sort(fields)
  
  end
  
  def self.data_for(columns)
  
  end
  
  def self.update(options = {})
    # preparations
    data_dir = "data/census/2000"
    old_dir = Dir.pwd
    
    if options[:download] and File.exists?(data_dir)
      FileUtils.rm_rf data_dir
    end
    
    if !File.exists?(data_dir)
      FileUtils.mkdir_p data_dir
      FileUtils.chdir data_dir
      download_census
      unzip_census
    else
      FileUtils.chdir data_dir
    end
    
    state_counts = {}
    
    states.keys.sort.each do |state|
      puts "[#{state}] Reading in pages..."
      # read in all the CSV (oh boy)
      pages = self.pages state
      
      ##### per-district files #####
      
      # Figure out the map of districts to rows for this state
      
      header = File.new "sl1/#{state}/sl500-in-sl040-#{state.downcase}geo.h10"
      
      # constructed in format "1" => "20" for "District 1 is at row index 20"
      districts = {}
      
      i = 0
      while !header.eof?
        row = header.readline
        name = row[200..289]
        if district = district_for(name) and districts[district].nil?
          districts[district] = i
        end
        i += 1
      end
      puts "[#{state}} Found #{districts.keys.size} districts..."
      
      # Loop through each region name, making a district for each congressional district
      district_count = 0
      districts.each do |name, i|
        puts "  [District #{name}] Parsing census data..."
        
        district = District.find_or_initialize_by_state_and_district state, name
        fill_district district, pages, i
        district.save!
         
        district_count += 1
      end
      
      state_counts[state] = district_count
      
      
      #####TODO: Per-state files ######
    end
    
    
    success_msg = "Updated district data from 2000 Census for #{state_counts.keys.size} states."
    state_counts.each do |state, count|
      success_msg << "\n[#{state}] #{count} districts."
    end
    
    ['SUCCESS', success_msg]
  rescue ActiveRecord::RecordInvalid => e
    ['FAILED', e.record.errors]
  rescue => e
    ['FAILED', "#{e.class}: #{e.message}"]
  ensure
    FileUtils.chdir old_dir
  end
  
  private
  
  # corresponds to page 00002 of dataset SL1, page 00059 of dataset SL3, etc.
  def self.page_map
    {
      :sl1 => [2],
      :sl3 => [4, 6, 59, 60]
    }
  end
  
  def self.pages(state)
    pages = {}
    ext_map = {:sl1 => 'h10', :sl3 => 's10'}
    page_map.each do |set, page_numbers|
      pages[set] = {}
      page_numbers.each do |number|
        filename = "sl500-in-sl040-#{state.downcase}#{zero_prefix number}.#{ext_map[set]}"
        page = FasterCSV.read "#{set}/#{state}/#{filename}"
        pages[set][number] = page
      end
    end
    pages
  end
  
  def self.fill_district(district, pages, row)
    population = pages[:sl1][2][row][86].to_i
    
    district.population = population
    
    district.blacks = percent pages[:sl1][2][row][105].to_f, population
    district.american_indians = percent pages[:sl1][2][row][106].to_f, population
    district.asians = percent pages[:sl1][2][row][107].to_f, population
    district.whites = percent pages[:sl1][2][row][104].to_f, population
    district.hispanics = percent pages[:sl1][2][row][125].to_f, population
    district.males = percent pages[:sl1][2][row][127].to_f, population
    district.females = percent pages[:sl1][2][row][151].to_f, population
    
    district.median_age = pages[:sl1][2][row][175]
    district.median_household_income = pages[:sl3][6][row][87]
    district.median_house_value = pages[:sl3][60][row][251]
    district.median_rent = pages[:sl3][59][row][202]
    
    district.unemployment = percent((pages[:sl3][4][row][145].to_i + pages[:sl3][4][row][152].to_i).to_f, population)
  end
  
  # turns a percent like 0.56789 into 56.8
  def self.percent(value, population)
    ((value / population) * 1000).round / 10.0
  end
  
  # Turns "59" into "00059", "6" into "00006", etc.
  def self.zero_prefix(n, z = 5)
    "#{"0" * (z - n.to_s.size)}#{n}"
  end
  
  def self.download_census
    system "wget http://www2.census.gov/census_2000/datasets/Summary_File_Extracts/110_Congressional_Districts/110_CD_HundredPercent/United_States/sl500-in-sl010-us_h10.zip"
    system "wget http://www2.census.gov/census_2000/datasets/Summary_File_Extracts/110_Congressional_Districts/110_CD_Sample/United_States/sl500-in-sl010-us_s10.zip"
  end
  
  def self.unzip_census
    FileUtils.rm_rf 'sl1'
    FileUtils.rm_rf 'sl3'
    
    system "unzip -o sl500-in-sl010-us_h10.zip -d sl1"
    states.keys.each do |state|
      zip_file = "sl1/sl500-in-sl040-#{state.downcase}_h10.zip"
      system "unzip #{zip_file} -d sl1/#{state}"
      FileUtils.rm zip_file
    end
    FileUtils.rm "sl500-in-sl010-us_h10.zip"
    
    system "unzip -o sl500-in-sl010-us_s10.zip -d sl3"
    states.keys.each do |state|
      zip_file = "sl3/sl500-in-sl040-#{state.downcase}_s10.zip"
      system "unzip #{zip_file} -d sl3/#{state}"
      FileUtils.rm zip_file
    end
    FileUtils.rm "sl500-in-sl010-us_s10.zip"
  end
  
  def self.district_for(name)
    case name
    when /District \(at Large\)/
      "0"
    when /District (\d+)/
      $1
    end
  end
  
  def self.states
    {
      # "US" => "00",
      "AL" => "01",
      "AK" => "02",
      # "Unknown 1" => "02", # American Samoa?
      "AZ" => "04",
      "AR" => "05",
      "CA" => "06",
      # "Unknown 2" => "07",
      "CO" => "08",
      "CT" => "09",
      "DE" => "10",
      "DC" => "11",
      "FL" => "12",
      "GA" => "13",
     #  "Unknown 3" => "14",
      "HI" => "15",
      "ID" => "16",
      "IL" => "17",
      "IN" => "18",
      "IA" => "19",
      "KS" => "20",
      "KY" => "21",
      "LA" => "22",
      "ME" => "23",
      "MD" => "24",
      "MA" => "25",
      "MI" => "26",
      "MN" => "27",
      "MS" => "28",
      "MO" => "29",
      "MT" => "30",
      "NE" => "31",
      "NV" => "32",
      "NH" => "33",
      "NJ" => "34",
      "NM" => "35",
      "NY" => "36",
      "NC" => "37",
      "ND" => "38",
      "OH" => "39",
      "OK" => "40",
      "OR" => "41",
      "PA" => "42",
      # "Unknown 4" => "43",
      "PR" => "72",
      "RI" => "44",
      "SC" => "45",
      "SD" => "46",
      "TN" => "47",
      "TX" => "48",
      "UT" => "49",
      "VT" => "50",
      "VA" => "51",
      # "Unknown 5" => "52", # Virgin Islands?
      "WA" => "53",
      "WV" => "54",
      "WI" => "55",
      "WY" => "56"
    }
  end

end