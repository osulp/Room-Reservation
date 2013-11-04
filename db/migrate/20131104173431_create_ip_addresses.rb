class CreateIpAddresses < ActiveRecord::Migration
  def change
    create_table :ip_addresses do |t|
      t.string :ip_address
      t.integer :ip_address_i
      t.references :auto_login, index: true

      t.timestamps
    end
    add_index :ip_addresses, :ip_address_i
  end
end
