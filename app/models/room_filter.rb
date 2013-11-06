class RoomFilter < ActiveRecord::Base
  belongs_to :room
  belongs_to :filter

  validates :room, :filter, presence: true
  has_many :filters
  has_many :rooms

end
