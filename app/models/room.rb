class Room < ActiveRecord::Base
  attr_accessible :floor, :name
  validates :floor, :name, presence: true
  validates :floor, numericality: {only_integer: true}
  has_many :reservations

end
