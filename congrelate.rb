#!/usr/bin/ruby

require 'rubygems'
require 'sinatra'
require 'htmlentities'


# Environment
require 'config/environment'


get '/' do
  @legislators = Legislator.active
  @data = get_columns @legislators, initial_columns
  @show_intro = params[:hide_intro].nil? 
  erb :index
end

get '/column.json' do
  response['Content-Type'] = 'text/json'
  column = class_for(params[:source]).field_for(Legislator.active, params[:column])
  column[:header] ||= params[:column].to_s.titleize
  column[:title] ||= params[:column].to_s.titleize
  column.to_json
end

get '/sources.json' do
  response['Content-Type'] = 'text/json'
  sources.to_json
end

get /\/table(?:\.([\w]+))?/ do
  @legislators = Legislator.active
  @data = get_columns @legislators, params
  @filter = !params[:filter].blank? ? params[:filter] : nil
  case params[:captures]
  when ['csv']
    response['Content-Type'] = 'text/csv'
    to_csv @data, @legislators, @filter
  when ['json']
    response['Content-Type'] = 'text/json'
    to_json @data, @legislators, @filter
  else
    erb :index
  end
end


helpers do
  
  def get_columns(legislators, params)
    data = {}
    source_keys.each do |source|
      source_class = class_for source
      if params[source]
        columns = {}
        params[source].each {|column, use| columns[column] = {} if use == '1'}
        
        columns.keys.each do |column|
          columns[column] = source_class.field_for legislators, column
        end
        
        data[source] = columns
      end
    end
    data
  end
  
  def initial_columns
    {:legislator => {
        'name' => '1',
        'state' => '1',
        'district' => '1'
    }}
  end
  
  def to_csv(data, legislators, filter = nil)
    FasterCSV.generate do |csv|
      to_array(data, legislators, filter).each {|row| csv << row}
    end
  end
  
  def to_json(data, legislators, filter = nil)
    to_array(data, legislators, filter).to_json
  end
  
  # creates a flat array of arrays of the data
  def to_array(data, legislators, filter = nil)
    array = []
    
    sources = sort_by_ref(data.keys, source_keys)
    header = []
    header << 'Bioguide ID'
    sources.each do |source|
      sort_fields(data[source].keys, source).each do |column|
        header << (data[source][column][:header] ? data[source][column][:header] : column.to_s.titleize)
      end
    end
    
    array << header
    
    legislators.each do |legislator|
      row = []
      row << legislator.bioguide_id
      
      matches_filter = false
      sources.each do |source|
        sort_fields(@data[source].keys, source).each do |column|
          cell = data[source][column][legislator.bioguide_id]
          cell = cell[:data] if cell.is_a?(Hash)
          
          if filter
            if cell =~ /#{filter}/i
              matches_filter = true
            end
          end
          
          row << cell
        end
      end
      array << row unless filter and !matches_filter
    end
    
    array
  end
  
  
  # little helpers
  
  def short_date(time)
    time.strftime '%m/%d/%y'
  end
  
  def sort_by_ref(array, reference)
    array.sort {|a, b| reference.index(a) <=> reference.index(b)}
  end
  
  def source_keys
    sources.map {|source| source.keyword.to_sym}
  end
  
  def class_for(source)
    source.to_s.camelize.constantize
  end
  
  def sources
    @@sources ||= Source.all
  end
  
  def source_for(keyword)
    Source.find_by_keyword keyword.to_s
  end

  def sort_fields(fields, source)
    class_for(source).sort(fields)
  end
  
  def field_checkbox(source, column, options = {})
    
    id = column_id source, column
    label = options[:hide_label] ? '' : field_label(source, column, options)
    <<-EOFC
    <div class="field_checkbox">
      <input id="#{id}" name="#{source}[#{column}]" type="checkbox" value="1" />
      <input type="hidden" value="#{column}" />
      #{label}
    </div>
    EOFC
  end
  
  def field_label(source, column, options = {})
    coder = HTMLEntities.new    
    column = coder.decode(column.to_s)
    
    id = column_id source, column
    title = options[:title] || column.titleize
    title = "<strong>#{title}</strong>" if options[:bold]
    "<label class=\"#{id}\" for=\"#{id}\">#{title}</label>"
  end
  
  def cycle_class
    @cycle_class = {nil => :odd, :odd => :even, :even => :odd}[@cycle_class]
  end
  
  def column_id(source, column)
    "#{source}_#{column.to_s.gsub(/[^\w\d]/,'_')}"
  end
  
  def ordinal(number)
    number.ordinalize.gsub number.to_s, ''
  end
  
  def asset(path)
    [path, File.mtime(File.join(Sinatra::Application.public, path)).to_i.to_s].join '?'
  end
  
end