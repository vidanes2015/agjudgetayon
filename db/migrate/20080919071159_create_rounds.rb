class CreateRounds < ActiveRecord::Migration
  def self.up
    create_table :rounds do |t|
      t.string :description
      t.float :max_score

      t.timestamps
    end
  end

  def self.down
    drop_table :rounds
  end
end
