class AddTruncatedAtToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :truncated_at, :timestamp
  end
end
