class CreateVotes < ActiveRecord::Migration

  def self.up
    create_table :votes do |t|
      t.string :bioguide_id, :roll_call_identifier, :position
    end
    
    add_index :votes, :roll_call_identifier
  end
  
  def self.down
    drop_table :votes
  end
  
end