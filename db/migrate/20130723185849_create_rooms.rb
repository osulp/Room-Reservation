class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.string :name
      t.integer :floor

      t.timestamps :precision => 6
    end
  end
end
