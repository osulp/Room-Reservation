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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140203170058) do

  create_table "auto_logins", force: true do |t|
    t.string   "username"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cleaning_record_rooms", force: true do |t|
    t.integer  "cleaning_record_id"
    t.integer  "room_id"
    t.datetime "created_at",         limit: 6
    t.datetime "updated_at",         limit: 6
  end

  add_index "cleaning_record_rooms", ["cleaning_record_id"], name: "index_cleaning_record_rooms_on_cleaning_record_id", using: :btree
  add_index "cleaning_record_rooms", ["room_id"], name: "index_cleaning_record_rooms_on_room_id", using: :btree

  create_table "cleaning_records", force: true do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.time     "start_time"
    t.time     "end_time"
    t.datetime "created_at", limit: 6
    t.datetime "updated_at", limit: 6
    t.string   "weekdays"
    t.datetime "deleted_at"
  end

  create_table "filters", force: true do |t|
    t.string   "name"
    t.datetime "created_at", limit: 6
    t.datetime "updated_at", limit: 6
  end

  create_table "ip_addresses", force: true do |t|
    t.string   "ip_address"
    t.integer  "ip_address_i",  limit: 8
    t.integer  "auto_login_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ip_addresses", ["auto_login_id"], name: "index_ip_addresses_on_auto_login_id", using: :btree
  add_index "ip_addresses", ["ip_address_i"], name: "index_ip_addresses_on_ip_address_i", using: :btree

  create_table "key_cards", force: true do |t|
    t.integer  "key",            limit: 8
    t.integer  "reservation_id"
    t.integer  "room_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "key_cards", ["key"], name: "index_key_cards_on_key", using: :btree
  add_index "key_cards", ["reservation_id"], name: "index_key_cards_on_reservation_id", using: :btree
  add_index "key_cards", ["room_id"], name: "index_key_cards_on_room_id", using: :btree

  create_table "reservations", force: true do |t|
    t.string   "user_onid"
    t.integer  "room_id"
    t.string   "reserver_onid"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "description"
    t.datetime "created_at",    limit: 6
    t.datetime "updated_at",    limit: 6
    t.datetime "deleted_at"
    t.datetime "truncated_at"
  end

  add_index "reservations", ["deleted_at"], name: "index_reservations_on_deleted_at", using: :btree
  add_index "reservations", ["end_time"], name: "index_reservations_on_end_time", using: :btree
  add_index "reservations", ["reserver_onid"], name: "index_reservations_on_reserver_onid", using: :btree
  add_index "reservations", ["room_id"], name: "index_reservations_on_room_id", using: :btree
  add_index "reservations", ["start_time"], name: "index_reservations_on_start_time", using: :btree
  add_index "reservations", ["user_onid"], name: "index_reservations_on_user_onid", using: :btree

  create_table "roles", force: true do |t|
    t.string   "onid"
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["onid"], name: "index_roles_on_onid", using: :btree
  add_index "roles", ["role"], name: "index_roles_on_role", using: :btree

  create_table "room_filters", force: true do |t|
    t.integer  "room_id"
    t.integer  "filter_id"
    t.datetime "created_at", limit: 6
    t.datetime "updated_at", limit: 6
  end

  add_index "room_filters", ["filter_id"], name: "index_room_filters_on_filter_id", using: :btree
  add_index "room_filters", ["room_id"], name: "index_room_filters_on_room_id", using: :btree

  create_table "room_hour_records", force: true do |t|
    t.integer  "room_id"
    t.integer  "room_hour_id"
    t.datetime "created_at",   limit: 6
    t.datetime "updated_at",   limit: 6
  end

  add_index "room_hour_records", ["room_hour_id"], name: "index_room_hour_records_on_room_hour_id", using: :btree
  add_index "room_hour_records", ["room_id"], name: "index_room_hour_records_on_room_id", using: :btree

  create_table "room_hours", force: true do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.time     "start_time"
    t.time     "end_time"
    t.datetime "created_at", limit: 6
    t.datetime "updated_at", limit: 6
    t.datetime "deleted_at"
  end

  create_table "rooms", force: true do |t|
    t.string   "name"
    t.integer  "floor"
    t.datetime "created_at",  limit: 6
    t.datetime "updated_at",  limit: 6
    t.text     "description"
    t.string   "image"
    t.string   "floor_map"
  end

  add_index "rooms", ["floor"], name: "index_rooms_on_floor", using: :btree
  add_index "rooms", ["name"], name: "index_rooms_on_name", using: :btree

  create_table "settings", force: true do |t|
    t.string   "key"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["key"], name: "key_udx", unique: true, using: :btree

  create_table "versions", force: true do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

end
