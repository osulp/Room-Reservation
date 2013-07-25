class Filter < ActiveRecord::Base
  attr_accessible :name
  validates :name, presence: true

  has_many :room_filters
  has_many :rooms, :through => :room_filters
end
