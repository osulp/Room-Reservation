class BuildSpecialHoursDevOnly < ActiveRecord::Migration
  def up
    unless Rails.env.production?
      create_table "special_hours", :force => true do |t|
        t.integer  "hours_id",                  :null => false
        t.datetime "start_date",                :null => false
        t.datetime "end_date",                  :null => false
        t.time     "open_time",                 :null => false
        t.time     "close_time",                :null => false
        t.string   "title",      :limit => 250
      end

      add_index "special_hours", ["start_date", "end_date"]
    end
  end

  def down
    unless Rails.env.production?
      drop_table :special_hours
    end
  end
end
