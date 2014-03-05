class KeyCard < ActiveRecord::Base
  has_paper_trail
  belongs_to :reservation
  belongs_to :room

  validates :room, :key, :presence => true
  validates :key, :numericality => {:only_integer => true}
  validate :reservation_room_valid

  private

  def reservation_room_valid
    return if !reservation
    errors.add(:base, "Keycard does not match reservation's room.") if reservation.room != room
  end
end
