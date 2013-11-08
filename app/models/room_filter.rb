class RoomFilter < ActiveRecord::Base
  belongs_to :room
  belongs_to :filter
end
