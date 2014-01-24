class AddFloorMapToRoom < ActiveRecord::Migration
  def change
    add_column :rooms, :floor_map, :string
  end
end
