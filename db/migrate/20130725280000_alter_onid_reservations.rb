class AlterOnidReservations < ActiveRecord::Migration
  def change
    change_column :reservations, :user_onid, :string
    change_column :reservations, :reserver_onid, :string
  end
end
