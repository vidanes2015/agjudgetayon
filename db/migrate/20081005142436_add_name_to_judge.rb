class AddNameToJudge < ActiveRecord::Migration
  def self.up
    add_column :judges, :name, :string
  end

  def self.down
    remove_column :judges, :name
  end
end
