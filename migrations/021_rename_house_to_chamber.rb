class RenameHouseToChamber < ActiveRecord::Migration

  def self.up
    rename_column :legislators, :house, :chamber
  end
  
  def self.down
    rename_column :legislators, :chamber, :house
  end

end