class BuildIntervalHoursDevOnly < ActiveRecord::Migration
  def up
    unless Rails.env.production?
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
      add_index "int_hours", ["start_date", "end_date"]
    end
  end

  def down
    unless Rails.env.production?
      drop_table :int_hours
    end
  end
end
