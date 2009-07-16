class AddPageantIdToScores < ActiveRecord::Migration
  def self.up
    add_column :scores, :pageant_id, :integer
  end

  def self.down
    remove_column :scores, :pageant_id
  end
end
