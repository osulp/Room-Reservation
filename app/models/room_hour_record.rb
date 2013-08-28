class RoomHourRecord < ActiveRecord::Base
  belongs_to :room
  belongs_to :room_hour
  # attr_accessible :title, :body
end
