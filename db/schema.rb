# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130828183517) do

  create_table "cleaning_record_rooms", :force => true do |t|
    t.integer  "cleaning_record_id"
    t.integer  "room_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "cleaning_record_rooms", ["cleaning_record_id"], :name => "index_cleaning_record_rooms_on_cleaning_record_id"
  add_index "cleaning_record_rooms", ["room_id"], :name => "index_cleaning_record_rooms_on_room_id"

  create_table "cleaning_records", :force => true do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.time     "start_time"
    t.time     "end_time"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "weekdays"
  end

  create_table "filters", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "hours", :force => true do |t|
    t.text     "open_time_1",         :null => false
    t.text     "close_time_1",        :null => false
    t.text     "open_time_5",         :null => false
    t.text     "close_time_5",        :null => false
    t.text     "open_time_6",         :null => false
    t.text     "close_time_6",        :null => false
    t.text     "open_time_7",         :null => false
    t.text     "close_time_7",        :null => false
    t.text     "int_open_time_1",     :null => false
    t.text     "int_close_time_1",    :null => false
    t.text     "int_open_time_6",     :null => false
    t.text     "int_close_time_6",    :null => false
    t.text     "int_open_time_7",     :null => false
    t.text     "int_close_time_7",    :null => false
    t.text     "published",           :null => false
    t.text     "loc",                 :null => false
    t.text     "int_term_start_date", :null => false
    t.text     "term",                :null => false
    t.datetime "term_start_date",     :null => false
    t.datetime "term_end_date",       :null => false
    t.text     "int_term_end_date",   :null => false
  end

  add_index "hours", ["term_start_date", "term_end_date"], :name => "term_dates_idx"

  create_table "int_hours", :force => true do |t|
    t.integer  "hours_id",       :null => false
    t.datetime "start_date",     :null => false
    t.datetime "end_date",       :null => false
    t.time     "open_time_wk",   :null => false
    t.time     "open_time_sat",  :null => false
    t.time     "open_time_sun",  :null => false
    t.time     "close_time_wk",  :null => false
    t.time     "close_time_sat", :null => false
    t.time     "close_time_sun", :null => false
  end

  add_index "int_hours", ["start_date", "end_date"], :name => "dates_idx"

  create_table "reservations", :force => true do |t|
    t.string   "user_onid"
    t.integer  "room_id"
    t.string   "reserver_onid"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "description"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "reservations", ["room_id"], :name => "index_reservations_on_room_id_id"

  create_table "room_filters", :force => true do |t|
    t.integer  "room_id"
    t.integer  "filter_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "room_filters", ["filter_id"], :name => "index_room_filters_on_filter_id"
  add_index "room_filters", ["room_id"], :name => "index_room_filters_on_room_id"

  create_table "room_hour_records", :force => true do |t|
    t.integer  "room_id"
    t.integer  "room_hour_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "room_hour_records", ["room_hour_id"], :name => "index_room_hour_records_on_room_hour_id"
  add_index "room_hour_records", ["room_id"], :name => "index_room_hour_records_on_room_id"

  create_table "room_hours", :force => true do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.time     "start_time"
    t.time     "end_time"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "rooms", :force => true do |t|
    t.string   "name"
    t.integer  "floor"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "special_hours", :force => true do |t|
    t.integer  "hours_id",                  :null => false
    t.datetime "start_date",                :null => false
    t.datetime "end_date",                  :null => false
    t.time     "open_time",                 :null => false
    t.time     "close_time",                :null => false
    t.string   "title",      :limit => 250
  end

  add_index "special_hours", ["start_date", "end_date"], :name => "dates_idx"

end
