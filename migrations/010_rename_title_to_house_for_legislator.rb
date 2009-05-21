class RenameTitleToHouseForLegislator < ActiveRecord::Migration

  def self.up
    rename_column :legislators, :title, :house
  end
  
  def self.down
    rename_column :legislators, :house, :title
  end

end