class CreateCleaningRecordRooms < ActiveRecord::Migration
  def change
    create_table :cleaning_record_rooms do |t|
      t.references :cleaning_record
      t.references :room

      t.timestamps :precision => 6
    end
    add_index :cleaning_record_rooms, :cleaning_record_id
    add_index :cleaning_record_rooms, :room_id
  end
end
