class CreateHoursTableOnlyDev < ActiveRecord::Migration
  def up
    unless Rails.env.production?
      create_table "hours", :force => true do |t|
        t.text     "open_time_1",         :null => false
        t.text     "close_time_1",        :null => false
        t.text     "open_time_5",         :null => false
        t.text     "close_time_5",        :null => false
        t.text     "open_time_6",         :null => false
        t.text     "close_time_6",        :null => false
        t.text     "open_time_7",         :null => false
        t.text     "close_time_7",        :null => false
        t.text     "int_open_time_1",     :null => true
        t.text     "int_close_time_1",    :null => true
        t.text     "int_open_time_6",     :null => true
        t.text     "int_close_time_6",    :null => true
        t.text     "int_open_time_7",     :null => true
        t.text     "int_close_time_7",    :null => true
        t.text     "published",           :null => false
        t.text     "loc",                 :null => false
        t.text     "int_term_start_date", :null => true
        t.text     "term",                :null => false
        t.datetime "term_start_date",     :null => false
        t.datetime "term_end_date",       :null => false
        t.text     "int_term_end_date",   :null => true
      end
      add_index "hours", ["term_start_date", "term_end_date"]
    end
  end

  def down
    unless Rails.env.production?
      drop_table :hours
    end
  end
end
