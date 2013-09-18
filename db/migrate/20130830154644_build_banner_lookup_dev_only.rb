class BuildBannerLookupDevOnly < ActiveRecord::Migration
  def up
    unless Rails.env.production?
      create_table "BannerLookup", :primary_key => "ID", :force => true do |t|
        t.string "onid",     :limit => 9,   :null => false
        t.string "status",   :limit => 30,  :null => false
        t.string "email",    :limit => 128, :null => false
        t.string "fullName", :limit => 41,  :null => false
        t.string "idHash",   :limit => 128, :null => false
      end

      add_index "BannerLookup", ["idHash"]
      add_index "BannerLookup", ["onid"]
    end
  end

  def down
    unless Rails.env.production?
      drop_table "BannerLookup"
    end
  end
end
