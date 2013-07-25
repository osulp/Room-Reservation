class RenameRoomIdReservations < ActiveRecord::Migration
  def change
    rename_column :reservations, :room_id_id, :room_id
  end
end
