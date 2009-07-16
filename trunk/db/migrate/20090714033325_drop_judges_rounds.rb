class DropJudgesRounds < ActiveRecord::Migration
  def self.up
    drop_table :judges_rounds
  end

  def self.down
    create_table :judges_rounds, :id=> false do |t|
      t.integer :round_id, :null => false
      t.integer :judge_id, :null => false
    end
  end
end
