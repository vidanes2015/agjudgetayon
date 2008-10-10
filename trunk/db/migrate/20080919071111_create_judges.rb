class CreateJudges < ActiveRecord::Migration
  def self.up
    create_table :judges do |t|
      t.string :alias
      t.string :username
      t.string :hashed_password
      t.string :salt

      t.timestamps
    end
  end

  def self.down
    drop_table :judges
  end
end
