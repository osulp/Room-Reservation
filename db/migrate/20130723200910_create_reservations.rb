class CreateReservations < ActiveRecord::Migration
  def change
    create_table :reservations do |t|
      t.integer :user_onid
      t.references :room_id
      t.integer :reserver_onid
      t.date :start_time
      t.date :end_time
      t.string :description

      t.timestamps
    end
    add_index :reservations, :room_id_id
  end
end
