class KeyCard < ActiveRecord::Base
  belongs_to :reservation
  belongs_to :room

  validates :room, :key, :presence => true
  validates :key, :numericality => {:only_integer => true}
  validates :key, :inclusion => {:in => (100000000000..999999999999), :message => "should be 12 digits"}
  validate :reservation_room_valid

  private

  def reservation_room_valid
    return if !reservation
    errors.add(:reservation, "is not for a room associated with this keycard.") if reservation.room != room
  end
end
