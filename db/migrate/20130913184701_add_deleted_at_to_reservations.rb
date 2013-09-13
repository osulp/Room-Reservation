class AddDeletedAtToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :deleted_at, :datetime
  end
end
