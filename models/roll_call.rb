class RollCall < ActiveRecord::Base 

  has_many :votes
  
  named_scope :bills, :conditions => 'bill_id is not null'

  def self.fields
  
  end
  
  def self.data_for
  
  end
  
  def self.update
    
  end
  
end