#!/usr/bin/ruby

require 'rubygems'
require 'sinatra'

# Environment
require 'config/environment'

# Models
load_models

# Controllers
get '/' do
  haml :index
end

get /\/table(?:\.([\w]+))?/ do
  @legislators = get_legislators
  @data = get_columns @legislators
  case params[:captures]
  when ['csv']
    response['Content-Type'] = 'text/csv'
    to_csv @data, @legislators
  else
    haml :table
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

  def get_columns(legislators)
    data = {}
    source_keys.each do |source|
      if params[source]
        if source_data = class_for(source).data_for(legislators, params[source])
          data[source] = source_data
        end
      end
    end
    data
  end
  
  def class_for(source)
    source.to_s.camelize.constantize
  end
  
  def sort_fields(fields, source)
    class_for(source).sort(fields)
  end
  
  def sources
    @@sources ||= Source.all
  end
  
  def source_keys
    sources.map {|source| source.keyword.to_sym}
  end
  
  def source_form(source)
    haml :"../sources/#{source.keyword}/form", :layout => false, :locals => {:source => source}
  end
  
  def sort_by_ref(array, reference)
    array.sort {|a, b| reference.index(a) <=> reference.index(b)}
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
  
end