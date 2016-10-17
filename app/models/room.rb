class Room < ApplicationRecord
  has_paper_trail
  validates :floor, :name, presence: true
  validates :floor, numericality: {only_integer: true}
  has_many :reservations
  has_many :room_filters
  has_many :filters, :through => :room_filters
  has_many :cleaning_record_rooms, :dependent => :destroy
  has_many :cleaning_records, :through => :cleaning_record_rooms
  has_many :room_hour_records, :dependent => :destroy
  has_many :room_hours, :through => :room_hour_records
  has_many :key_cards
  mount_uploader :image, ImageUploader
  mount_uploader :floor_map, ImageUploader
end
