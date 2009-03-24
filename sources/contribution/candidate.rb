class Candidate < ActiveRecord::Base
  
  validates_presence_of :bioguide_id, :crp_id, :cycle
  validates_uniqueness_of :bioguide_id, :scope => :cycle
  validates_uniqueness_of :crp_id, :scope => :cycle
  
end