class AddDeletedAtToRoomHours < ActiveRecord::Migration
  def change
    add_column :room_hours, :deleted_at, :datetime
  end
end
