#!/usr/bin/ruby

require 'rubygems'
require 'sinatra'

# Environment
require 'config/environment'

load_sources

get '/' do
  @legislators = get_legislators
  @data = get_columns @legislators, initial_columns
  erb :index
end

get '/column.json' do
  response['Content-Type'] = 'text/json'
  column = class_for(params[:source]).field_for(get_legislators, params[:column])
  column[:header] ||= params[:column].to_s.titleize
  column[:title] ||= params[:column].to_s.titleize
  column.to_json
end

get /\/table(?:\.([\w]+))?/ do
  @legislators = get_legislators
  @data = get_columns @legislators, params
  case params[:captures]
  when ['csv']
    response['Content-Type'] = 'text/csv'
    to_csv @data, @legislators
  when ['json']
    response['Content-Type'] = 'text/json'
    to_json @data, @legislators
  else
    status 404
    'Unsupported format.'
  end
end


helpers do

  def get_legislators
    if params[:filters]
      Legislator.active.filter params[:filters]
    else
      Legislator.active
    end
  end
  
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
  
  def to_csv(data, legislators)
    FasterCSV.generate do |csv|
      to_array(data, legislators).each {|row| csv << row}
    end
  end
  
  def to_json(data, legislators)
    to_array(data, legislators).to_json
  end
  
  # creates a flat array of arrays of the data
  def to_array(data, legislators)
    array = []
    
    sources = sort_by_ref(data.keys, source_keys)
    header = []
    sources.each do |source|
      sort_fields(data[source].keys, source).each do |column|
        header << (data[source][column][:header] ? data[source][column][:header] : column.to_s.titleize)
      end
    end
    array << header
    
    legislators.each do |legislator|
      row = []
      sources.each do |source|
        sort_fields(@data[source].keys, source).each do |column|
          row << data[source][column][legislator.bioguide_id]
        end
      end
      array << row
    end
    
    array
  end
  
  # little helpers
  
  def phrase_id(string)
    string.gsub(' ','').underscore
  end
  
  def short_date(time)
    time.strftime '%m/%d/%y'
  end
  
  def sort_by_ref(array, reference)
    array.sort {|a, b| reference.index(a) <=> reference.index(b)}
  end
  
  def source_keys
    sources.map {|source| source.keyword.to_sym}
  end
  
  def sources
    @@sources ||= Source.all
  end
  
  def other_sources
    sources[1..-1]
  end
  
  def class_for(source)
    source.to_s.camelize.constantize
  end
  
  def source_for(keyword)
    Source.find_by_keyword keyword.to_s
  end
  
  def sort_fields(fields, source)
    class_for(source).sort(fields)
  end
  
  def cycle_class
    @cycle_class = {nil => :odd, :odd => :even, :even => :odd}[@cycle_class]
  end
  
  def column_header(text)
    text.to_s.titleize
  end
  
  def popup_form?(source)
    class_for(source.keyword).respond_to?(:popup_form?) and class_for(source.keyword).popup_form?
  end
  
  def inline_form_for(source, options = {})
    erb :inline_form, :layout => false, :locals => {:source => source, :options => options}
  end
  
  def popup_form_for(source, options = {})
    erb :popup_form, :layout => false, :locals => {:source => source, :options => options}
  end
  
  def form_for(source, options = {})
    erb :"../sources/#{source.keyword}/form", :layout => false, :locals => {:source => source}.merge(options)
  end
  
end