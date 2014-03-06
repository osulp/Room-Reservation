class Openroom::Room < ActiveRecord::Base
  establish_connection "openroom_#{Rails.env}"
  has_many :reservations, :foreign_key => :roomid, :primary_key => :roomid, :class_name => "Openroom::Reservation"
  belongs_to :room_group, :class_name => "Openroom::RoomGroup", :foreign_key => :roomgroupid, :primary_key => :roomgroupid
  has_many :keycards, :foreign_key => :roomid, :primary_key => :roomid, :class_name => "Openroom::Keycard"
  def converted
    r = ::Room.where(:name => roomname).first || ::Room.new
    r.name = roomname
    r.description = roomdescription unless roomdescription.blank?
    r.floor = room_group.roomgroupname[0,1].to_i
    keycards.each do |key|
      new_key = key.converted
      new_key.room = r
      r.key_cards << new_key
    end
    r
  end
end
