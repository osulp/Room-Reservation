class Openroom::RoomGroup < ActiveRecord::Base
  establish_connection :"openroom_#{Rails.env}"
  self.table_name = "roomgroups"
  has_many :rooms, :class_name => "Openroom::Room", :foreign_key => :roomgroupid, :primary_key => :roomgroupid
end
