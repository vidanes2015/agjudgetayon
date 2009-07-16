class AddPageantToRound < ActiveRecord::Migration
  def self.up
    add_column :rounds, :pageant_id, :integer
  end

  def self.down
    remove_column :rounds, :pageant_id
  end
end
