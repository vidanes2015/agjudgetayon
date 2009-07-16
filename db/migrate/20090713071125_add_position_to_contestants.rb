class AddPositionToContestants < ActiveRecord::Migration
  def self.up
    add_column :contestants, :position, :integer
  end

  def self.down
    remove_column :contestants, :position
  end
end
