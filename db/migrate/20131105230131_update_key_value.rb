class UpdateKeyValue < ActiveRecord::Migration
  def change
    reversible do |dir|
      change_table :key_cards do |t|
        dir.up {t.change :key, :integer, :limit => 8}
        dir.down {t.change :key, :integer}
      end
    end
  end
end
