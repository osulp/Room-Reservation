class CreateRoomFilters < ActiveRecord::Migration
  def change
    create_table :room_filters do |t|
      t.references :room
      t.references :filter

      t.timestamps :precision => 6
    end
    add_index :room_filters, :room_id
    add_index :room_filters, :filter_id
  end
end
