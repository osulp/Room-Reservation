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

  create_table "BannerLookup", primary_key: "ID", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "onid",     limit: 9,   null: false
    t.string "status",   limit: 30,  null: false
    t.string "email",    limit: 128, null: false
    t.string "fullName", limit: 41,  null: false
    t.string "idHash",   limit: 128, null: false
    t.index ["idHash"], name: "index_BannerLookup_on_idHash", using: :btree
    t.index ["onid"], name: "index_BannerLookup_on_onid", using: :btree
  end

  create_table "auto_logins", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "username"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cleaning_record_rooms", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "cleaning_record_id"
    t.integer  "room_id"
    t.datetime "created_at",         precision: 6
    t.datetime "updated_at",         precision: 6
    t.index ["cleaning_record_id"], name: "index_cleaning_record_rooms_on_cleaning_record_id", using: :btree
    t.index ["room_id"], name: "index_cleaning_record_rooms_on_room_id", using: :btree
  end

  create_table "cleaning_records", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.time     "start_time"
    t.time     "end_time"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string   "weekdays"
    t.datetime "deleted_at"
  end

  create_table "filters", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
  end

  create_table "hours", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text     "open_time_1",         limit: 65535, null: false
    t.text     "close_time_1",        limit: 65535, null: false
    t.text     "open_time_5",         limit: 65535, null: false
    t.text     "close_time_5",        limit: 65535, null: false
    t.text     "open_time_6",         limit: 65535, null: false
    t.text     "close_time_6",        limit: 65535, null: false
    t.text     "open_time_7",         limit: 65535, null: false
    t.text     "close_time_7",        limit: 65535, null: false
    t.text     "int_open_time_1",     limit: 65535
    t.text     "int_close_time_1",    limit: 65535
    t.text     "int_open_time_6",     limit: 65535
    t.text     "int_close_time_6",    limit: 65535
    t.text     "int_open_time_7",     limit: 65535
    t.text     "int_close_time_7",    limit: 65535
    t.text     "published",           limit: 65535, null: false
    t.text     "loc",                 limit: 65535, null: false
    t.text     "int_term_start_date", limit: 65535
    t.text     "term",                limit: 65535, null: false
    t.datetime "term_start_date",                   null: false
    t.datetime "term_end_date",                     null: false
    t.text     "int_term_end_date",   limit: 65535
    t.index ["term_start_date", "term_end_date"], name: "index_hours_on_term_start_date_and_term_end_date", using: :btree
  end

  create_table "int_hours", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "hours_id",       null: false
    t.datetime "start_date",     null: false
    t.datetime "end_date",       null: false
    t.time     "open_time_wk",   null: false
    t.time     "open_time_sat",  null: false
    t.time     "open_time_sun",  null: false
    t.time     "close_time_wk",  null: false
    t.time     "close_time_sat", null: false
    t.time     "close_time_sun", null: false
    t.index ["start_date", "end_date"], name: "index_int_hours_on_start_date_and_end_date", using: :btree
  end

  create_table "ip_addresses", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "ip_address"
    t.bigint   "ip_address_i"
    t.integer  "auto_login_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["auto_login_id"], name: "index_ip_addresses_on_auto_login_id", using: :btree
    t.index ["ip_address_i"], name: "index_ip_addresses_on_ip_address_i", using: :btree
  end

  create_table "key_cards", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint   "key"
    t.integer  "reservation_id"
    t.integer  "room_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["key"], name: "index_key_cards_on_key", using: :btree
    t.index ["reservation_id"], name: "index_key_cards_on_reservation_id", using: :btree
    t.index ["room_id"], name: "index_key_cards_on_room_id", using: :btree
  end

  create_table "reservations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "user_onid"
    t.integer  "room_id"
    t.string   "reserver_onid"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "description"
    t.datetime "created_at",    precision: 6
    t.datetime "updated_at",    precision: 6
    t.datetime "deleted_at"
    t.datetime "truncated_at"
    t.index ["deleted_at"], name: "index_reservations_on_deleted_at", using: :btree
    t.index ["end_time"], name: "index_reservations_on_end_time", using: :btree
    t.index ["reserver_onid"], name: "index_reservations_on_reserver_onid", using: :btree
    t.index ["room_id"], name: "index_reservations_on_room_id", using: :btree
    t.index ["start_time"], name: "index_reservations_on_start_time", using: :btree
    t.index ["user_onid"], name: "index_reservations_on_user_onid", using: :btree
  end

  create_table "roles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "onid"
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["onid"], name: "index_roles_on_onid", using: :btree
    t.index ["role"], name: "index_roles_on_role", using: :btree
  end

  create_table "room_filters", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "room_id"
    t.integer  "filter_id"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.index ["filter_id"], name: "index_room_filters_on_filter_id", using: :btree
    t.index ["room_id"], name: "index_room_filters_on_room_id", using: :btree
  end

  create_table "room_hour_records", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "room_id"
    t.integer  "room_hour_id"
    t.datetime "created_at",   precision: 6
    t.datetime "updated_at",   precision: 6
    t.index ["room_hour_id"], name: "index_room_hour_records_on_room_hour_id", using: :btree
    t.index ["room_id"], name: "index_room_hour_records_on_room_id", using: :btree
  end

  create_table "room_hours", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.time     "start_time"
    t.time     "end_time"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.datetime "deleted_at"
  end

  create_table "rooms", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.integer  "floor"
    t.datetime "created_at",                precision: 6
    t.datetime "updated_at",                precision: 6
    t.text     "description", limit: 65535
    t.string   "image"
    t.string   "floor_map"
    t.index ["floor"], name: "index_rooms_on_floor", using: :btree
    t.index ["name"], name: "index_rooms_on_name", using: :btree
  end

  create_table "settings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "key"
    t.text     "value",      limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["key"], name: "key_udx", unique: true, using: :btree
  end

  create_table "special_hours", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "hours_id",               null: false
    t.datetime "start_date",             null: false
    t.datetime "end_date",               null: false
    t.time     "open_time",              null: false
    t.time     "close_time",             null: false
    t.string   "title",      limit: 250
    t.index ["start_date", "end_date"], name: "index_special_hours_on_start_date_and_end_date", using: :btree
  end

  create_table "versions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "item_type",                null: false
    t.integer  "item_id",                  null: false
    t.string   "event",                    null: false
    t.string   "whodunnit"
    t.text     "object",     limit: 65535
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
  end

end
