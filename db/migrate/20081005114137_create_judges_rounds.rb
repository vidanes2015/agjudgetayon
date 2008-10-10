class CreateJudgesRounds < ActiveRecord::Migration
  def self.up
    create_table :judges_rounds, :id=> false do |t|
      t.integer :round_id, :null => false
      t.integer :judge_id, :null => false
    end
  end

  def self.down
    drop_table :judges_rounds
  end
end
