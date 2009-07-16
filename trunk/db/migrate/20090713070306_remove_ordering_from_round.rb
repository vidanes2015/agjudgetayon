class RemoveOrderingFromRound < ActiveRecord::Migration
  def self.up
    remove_column :rounds, :ordering
  end

  def self.down
     add_column :rounds, :ordering, :integer
  end
end
