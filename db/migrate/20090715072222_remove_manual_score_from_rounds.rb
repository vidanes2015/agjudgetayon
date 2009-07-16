class RemoveManualScoreFromRounds < ActiveRecord::Migration
  def self.up
    remove_column :rounds, :manual_score
  end

  def self.down
    add_column :rounds, :manual_score, :float
  end
end
