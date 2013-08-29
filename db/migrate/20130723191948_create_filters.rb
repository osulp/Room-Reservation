class CreateFilters < ActiveRecord::Migration
  def change
    create_table :filters do |t|
      t.string :name

      t.timestamps :precision => 6
    end
  end
end
