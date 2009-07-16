class AddPageantIdToJudge < ActiveRecord::Migration
  def self.up
    add_column :judges, :pageant_id, :integer
  end

  def self.down
    remove_column :judges, :pageant_id
  end
end
