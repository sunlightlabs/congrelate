class AddIndicesToContributions < ActiveRecord::Migration

  def self.up

    add_index :contributions, :bioguide_id
    add_index :contributions, :crp_id
    add_index :contributions, :industry
    add_index :contributions, :cycle
    add_index :contributions, :amount
    
  end
  
  def self.down
    
    drop_index :contributions, :bioguide_id
    drop_index :contributions, :crp_id
    drop_index :contributions, :industry
    drop_index :contributions, :cycle
    drop_index :contributions, :amount

  end

end