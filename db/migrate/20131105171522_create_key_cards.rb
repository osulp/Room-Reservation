class CreateKeyCards < ActiveRecord::Migration
  def change
    create_table :key_cards do |t|
      t.integer :key
      t.references :reservation, index: true
      t.references :room, index: true

      t.timestamps
    end
    add_index :key_cards, :key
  end
end
