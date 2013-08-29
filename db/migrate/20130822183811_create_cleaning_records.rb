class CreateCleaningRecords < ActiveRecord::Migration
  def change
    create_table :cleaning_records do |t|
      t.date :start_date
      t.date :end_date
      t.time :start_time
      t.time :end_time

      t.timestamps :precision => 6
    end
  end
end
