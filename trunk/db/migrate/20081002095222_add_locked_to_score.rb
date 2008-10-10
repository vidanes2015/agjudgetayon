class AddLockedToScore < ActiveRecord::Migration
  def self.up
    add_column :scores, :locked, :boolean
  end

  def self.down
    remove_column :scores, :locked
  end
end
