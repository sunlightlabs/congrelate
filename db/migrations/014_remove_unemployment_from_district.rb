class RemoveUnemploymentFromDistrict < ActiveRecord::Migration

  def self.up
    remove_column :districts, :unemployment
  end
  
  def self.down
    add_column :districts, :unemployment, :float
  end
  
end