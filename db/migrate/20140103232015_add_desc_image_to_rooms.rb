class AddDescImageToRooms < ActiveRecord::Migration
  def change
    add_column :rooms, :description, :text
    add_column :rooms, :image, :string
  end
end
