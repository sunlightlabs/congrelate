class Update < ActiveRecord::Base
  validates_presence_of :status, :source, :elapsed_time
end