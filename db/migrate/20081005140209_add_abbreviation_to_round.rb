class AddAbbreviationToRound < ActiveRecord::Migration
  def self.up
    add_column :rounds, :abbreviation, :string, :limit => 8
  end

  def self.down
    remove_column :rounds, :abbreviation
  end
end
