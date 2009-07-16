class AddManualScoreToRounds < ActiveRecord::Migration
  def self.up
    add_column :rounds, :manual, :boolean
    add_column :rounds, :manual_score, :float
  end

  def self.down
    remove_column :rounds, :manual
    remove_column :rounds, :manual_score
  end
end
