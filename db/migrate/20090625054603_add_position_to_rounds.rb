class AddPositionToRounds < ActiveRecord::Migration
  def self.up
    add_column :rounds, :position, :integer
  end

  def self.down
    remove_column :rounds, :position
  end
end
