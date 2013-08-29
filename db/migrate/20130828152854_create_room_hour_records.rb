class CreateRoomHourRecords < ActiveRecord::Migration
  def change
    create_table :room_hour_records do |t|
      t.references :room
      t.references :room_hour

      t.timestamps :precision => 6
    end
    add_index :room_hour_records, :room_id
    add_index :room_hour_records, :room_hour_id
  end
end
