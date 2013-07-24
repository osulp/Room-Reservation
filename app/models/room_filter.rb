class RoomFilter < ActiveRecord::Base
  belongs_to :room
  belongs_to :filter
  # attr_accessible :title, :body

  validates :room, :filter, presence: true
  has_many :filters
  has_many :rooms

end
