class AddIndexesToReservations < ActiveRecord::Migration
  def change
    # Reservation Indexes
    add_index(:reservations, :user_onid)
    add_index(:reservations, :reserver_onid)
    add_index(:reservations, :start_time)
    add_index(:reservations, :end_time)
    add_index(:reservations, :deleted_at)

    # Room Indexes
    add_index(:rooms, :name)
  end
end
