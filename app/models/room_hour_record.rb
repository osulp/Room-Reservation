class RoomHourRecord < ApplicationRecord
  belongs_to :room, optional: true
  belongs_to :room_hour, :touch => true, optional: true
end
