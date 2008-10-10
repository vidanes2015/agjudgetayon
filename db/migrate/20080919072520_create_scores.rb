class CreateScores < ActiveRecord::Migration
  def self.up
    create_table :scores do |t|
      t.integer :contestant_id
      t.integer :judge_id
      t.integer :round_id
      t.float :value

      t.timestamps
    end
  end

  def self.down
    drop_table :scores
  end
end
