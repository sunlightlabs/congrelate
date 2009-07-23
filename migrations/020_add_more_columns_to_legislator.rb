class AddMoreColumnsToLegislator < ActiveRecord::Migration

  def self.up
    add_column :legislators, :phone, :string
    add_column :legislators, :website, :string
    add_column :legislators, :twitter_id, :string
    add_column :legislators, :youtube_url, :string
  end
  
  def self.down
    remove_column :legislators, :youtube_url, :twitter_id, :website, :phone
  end

end