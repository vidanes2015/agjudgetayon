class AddOrderingToRound < ActiveRecord::Migration
  def self.up
    add_column :rounds, :ordering, :integer
  end

  def self.down
    remove_column :rounds, :ordering
  end
end
