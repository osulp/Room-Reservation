class AddDeletedAtToCleaningRecords < ActiveRecord::Migration
  def change
    add_column :cleaning_records, :deleted_at, :datetime
  end
end
