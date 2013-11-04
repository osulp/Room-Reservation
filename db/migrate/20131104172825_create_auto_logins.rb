class CreateAutoLogins < ActiveRecord::Migration
  def change
    create_table :auto_logins do |t|
      t.string :username

      t.timestamps
    end
  end
end
