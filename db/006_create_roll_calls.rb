class CreateRollCalls < ActiveRecord::Migration

  def self.up
    create_table :roll_calls do |t|
      t.string :type, :question, :result, :session, :year, :bill_identifier, :identifier
      t.integer :congress
    end
    
    add_index :roll_calls, :identifier
    add_index :roll_calls, :bill_identifier
    add_index :roll_calls, :type
  end
  
  def self.down
    drop_table :roll_calls
  end

end