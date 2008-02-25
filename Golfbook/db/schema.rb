# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 22) do

  create_table "competition_rounds", :force => true do |t|
    t.integer  "competition_id"
    t.integer  "round_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "winning_round",  :default => false
  end

  create_table "competitions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "course_id"
    t.string   "name",        :default => "",   :null => false
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "start_date"
    t.date     "end_date"
    t.boolean  "open",        :default => true
  end

  create_table "competitors", :force => true do |t|
    t.integer  "user_id"
    t.integer  "competition_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "courses", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "latitude",      :precision => 15, :scale => 10
    t.decimal  "longitude",     :precision => 15, :scale => 10
    t.string   "location_text"
  end

  create_table "courses_users", :id => false, :force => true do |t|
    t.integer  "user_id"
    t.integer  "course_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ratings", :force => true do |t|
    t.integer  "rating",                      :default => 0
    t.datetime "created_at",                                  :null => false
    t.string   "rateable_type", :limit => 15, :default => "", :null => false
    t.integer  "rateable_id",                 :default => 0,  :null => false
    t.integer  "user_id",                     :default => 0,  :null => false
  end

  add_index "ratings", ["user_id"], :name => "fk_ratings_user"

  create_table "rounds", :force => true do |t|
    t.integer  "score"
    t.date     "date_played"
    t.integer  "user_id"
    t.integer  "course_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :default => "", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "tour_dates", :force => true do |t|
    t.integer  "tour_id"
    t.integer  "course_id"
    t.date     "to_play_at", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tour_players", :force => true do |t|
    t.integer  "user_id"
    t.integer  "tour_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tours", :force => true do |t|
    t.integer  "user_id"
    t.string   "name",        :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
  end

  create_table "users", :force => true do |t|
    t.integer  "facebook_uid",                                 :null => false
    t.string   "session_key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "latitude",     :precision => 15, :scale => 10
    t.decimal  "longitude",    :precision => 15, :scale => 10
    t.string   "address"
  end

  create_table "wishlists", :force => true do |t|
    t.date     "target_date"
    t.integer  "user_id"
    t.integer  "course_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
