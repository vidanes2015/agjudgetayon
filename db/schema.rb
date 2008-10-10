# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20081005142436) do

  create_table "contestants", :force => true do |t|
    t.integer  "number"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "judges", :force => true do |t|
    t.string   "alias"
    t.string   "username"
    t.string   "hashed_password"
    t.string   "salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  create_table "judges_rounds", :id => false, :force => true do |t|
    t.integer "round_id", :null => false
    t.integer "judge_id", :null => false
  end

  create_table "rounds", :force => true do |t|
    t.string   "description"
    t.float    "max_score"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ordering"
    t.string   "abbreviation", :limit => 8
  end

  create_table "scores", :force => true do |t|
    t.integer  "contestant_id"
    t.integer  "judge_id"
    t.integer  "round_id"
    t.float    "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "locked"
  end

end
