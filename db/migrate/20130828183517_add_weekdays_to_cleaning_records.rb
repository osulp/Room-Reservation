class AddWeekdaysToCleaningRecords < ActiveRecord::Migration
  def change
    add_column :cleaning_records, :weekdays, :string
  end
end
