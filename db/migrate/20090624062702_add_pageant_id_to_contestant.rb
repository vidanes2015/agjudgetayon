class AddPageantIdToContestant < ActiveRecord::Migration
  def self.up
    add_column :contestants, :pageant_id, :integer
  end

  def self.down
    remove_column :contestants, :pageant_id
  end
end
