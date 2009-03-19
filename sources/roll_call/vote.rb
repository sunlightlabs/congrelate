class Vote < ActiveRecord::Base

  belongs_to :roll_call
  
  validates_presence_of :roll_call_identifier, :position
  
end