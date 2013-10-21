class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :onid
      t.string :role

      t.timestamps
    end
    add_index :roles, :onid
    add_index :roles, :role
  end
end
