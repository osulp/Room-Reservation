class AddFloorIndexToRooms < ActiveRecord::Migration
  def change
    add_index :rooms, :floor
  end
end
