class CreatePageants < ActiveRecord::Migration
  def self.up
    create_table :pageants do |t|
      t.string :title

      t.timestamps
    end
  end

  def self.down
    drop_table :pageants
  end
end
