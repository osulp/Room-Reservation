class AlterDatetimeReservations < ActiveRecord::Migration
  def change
    change_column :reservations, :start_time, :datetime
    change_column :reservations, :end_time, :datetime
  end
end
