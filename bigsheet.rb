#!/usr/bin/ruby

require 'rubygems'
require 'sinatra'

# Environment
require 'config/environment'

load_models

get '/' do
  haml :index
end

# temporary
get '/old' do
  haml :old
end

# returns a column of data in json form
get '/column' do
  #response['Content-Type'] = 'text/json'
  class_for(params[:source]).field_for(get_legislators, params[:column]).to_json
end

# API
get /\/table(?:\.([\w]+))?/ do
  @legislators = get_legislators
  @data = get_columns @legislators
  case params[:captures]
  when ['csv']
    response['Content-Type'] = 'text/csv'
    to_csv @data, @legislators
  else
    status 404
    'Unsupported format.'
  end
end

helpers do

  def source_form(source)
    haml :"../sources/#{source.keyword}/form", :layout => false, :locals => {:source => source}
  end

  def get_legislators
    if params[:filters]
      Legislator.active.filter params[:filters]
    else
      Legislator.active
    end
  end
  
  def get_columns(legislators)
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
  
  def to_csv(data, legislators)
    FasterCSV.generate do |csv|
      to_array(data, legislators).each {|row| csv << row}
    end
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
  
  def sort_by_ref(array, reference)
    array.sort {|a, b| reference.index(a) <=> reference.index(b)}
  end
  
  def source_keys
    sources.map {|source| source.keyword.to_sym}
  end
  
  def sources
    @@sources ||= Source.all
  end
  
  def class_for(source)
    source.to_s.camelize.constantize
  end
  
  def sort_fields(fields, source)
    class_for(source).sort(fields)
  end
  
end