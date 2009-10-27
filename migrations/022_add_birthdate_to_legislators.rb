class AddBirthdateToLegislators < ActiveRecord::Migration

  def self.up
    add_column :legislators, :birthdate, :timestamp
  end
  
  def self.down
    remove_column :legislators, :birthdate
  end

end