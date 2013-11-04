class UpdateIpAddressesIpAddressColumn < ActiveRecord::Migration
  def change
    reversible do |dir|
      change_table :ip_addresses do |t|
        dir.up {t.change :ip_address_i, :integer, :limit => 8}
        dir.down {t.change :ip_address_i, :integer}
      end
    end
  end
end
