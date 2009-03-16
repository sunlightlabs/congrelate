class District < ActiveRecord::Base

  def self.sort(fields)
  
  end
  
  def self.data_for(columns)
  
  end
  
  def self.update(options = {})
    # preparations
    data_dir = "data/census/2000"
    
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
      # read in all the CSV (oh boy)
      pages = self.pages state
      
      # constructed in format "1" => "20" for "District 1 is at row index 20"
      districts = {}
      
      header = File.new "sl1/#{state}/sl500-in-sl040-#{state.downcase}geo.h10"
      
      i = 0
      while !f.eof?
        row = header.readline
        # if row is a district, get district number
          # how do we tell the right row for the whole district?
        # store row index (i) for that district
        i += 1
      end
      
      # Loop through each region name, making a district for each congressional district
      district_count = 0
      districts.each do |district, i|
#         puts "  [District #{district}]"
#         
#         district = District.find_or_initialize_by_state_and_district state, district_name
#         fill_district district, pages, i
#         district.save!
#         
#         district_count += 1
      end
      
      state_counts[state] = district_count
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
  end
  
  private
  
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
      pages[set] = page_numbers.map do |number|
        filename = "sl500-in-sl040-#{state.downcase}#{zero_prefix number}.#{ext_map[set]}"
        FasterCSV.read "#{set}/#{state}/#{filename}"
      end
    end
    pages
  end
  
  # Turns "59" into "00059", "6" into "00006", etc.
  def self.zero_prefix(n, z = 5)
    "#{"0" * (z - n.to_s.size)}#{n}"
  end
  
  def self.fill_district(district, pages, row)
    population = pages[0][row][15].to_i
    
    district.population = population
    district.males = percent pages[0][row][16].to_f, population
    district.females = percent pages[0][row][17].to_f, population
    district.median_age = pages[0][row][31].to_f
    
    district.whites = percent pages[0][row][59].to_f, population
    district.blacks = percent pages[0][row][60].to_f, population
    district.american_indians = percent pages[0][row][61].to_f, population
    district.asians = percent pages[0][row][62].to_f, population
    district.hispanics = percent pages[0][row][66].to_f, population
    
    district.family_size = pages[0][row][99].to_f
    
    district.high_school = pages[1][row][29].to_f
    district.bachelors = pages[1][row][30].to_f
    
    district.arabs = percent pages[1][row][89].to_f, population
    district.english = percent pages[1][row][93].to_f, population
    district.french = percent pages[1][row][94].to_f, population
    district.germans = percent pages[1][row][96].to_f, population
    district.irish = percent pages[1][row][99].to_f, population
    district.russians = percent pages[1][row][105].to_f, population
    district.americans = percent pages[1][row][113].to_f, population
    
    district.unemployment = pages[2][row][20].to_f
    
    district.median_household_income = pages[2][row][72].to_f
    district.median_house_value = pages[3][row][79].to_f
    district.median_monthly_mortgage = pages[3][row][88].to_f
    district.median_rent = pages[3][row][107].to_f
  end
  
  # turns a percent like 0.56789 into 56.8
  def self.percent(value, population)
    ((value / population) * 1000).round / 10.0
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
  
  def self.district_for(district)
    case district
    when /District \(at Large\)/
      "0"
    when /District (\d+),/
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