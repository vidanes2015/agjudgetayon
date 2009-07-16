class RemoveNumberFromContestants < ActiveRecord::Migration
  def self.up
    remove_column :contestants, :number
  end

  def self.down
    add_column :contestants, :number, :integer
  end
end
