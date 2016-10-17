class RoomFilter < ApplicationRecord
  belongs_to :room, optional: true
  belongs_to :filter, optional: true
end
