class Keycards::CheckoutService
  include ActiveModel::Model
  attr_accessor :keycard, :user, :reservation
  validate :append_keycard_errors
  validate :append_reservation_errors
  validate :user_can_checkout
  validate :reservation_not_expired
  validate :key_card_available
  validate :reservation_available
  validate :key_card_matches_reservation

  def initialize(keycard, reservation, user)
    self.keycard = keycard
    self.user = user
    self.reservation = reservation
  end

  def user=(user)
    if user.kind_of?(String)
      user = User.new(user)
    end
    @user = user
  end

  def save
    return false unless self.valid?
    keycard.reservation = reservation
    return keycard.save
  end

  def attributes
    {"keycard" => nil, "reservation" => nil}
  end

  def as_json(options={})
    {"keycard" => keycard, "reservation" => reservation}
  end

  private

  def append_keycard_errors
    return if !keycard
    unless keycard.valid?
      keycard.errors.full_messages.each do |msg|
        self.errors.add(:base, msg)
      end
    end
  end

  def append_reservation_errors
    return if !reservation
    unless reservation.valid?
      reservation.errors.full_messages.each do |msg|
        self.errors.add(:base, msg)
      end
    end
  end

  def reservation_not_expired
    return if !reservation
    self.errors.add(:reservation, "is expired and so can not be checked out") if reservation.expired?
  end

  def key_card_available
    return if !keycard
    self.errors.add(:key_card, "is already attached to another reservation") if keycard.reservation
  end

  def reservation_available
    return if !keycard
    self.errors.add(:reservation, "is already checked out") if reservation.key_card
  end

  def key_card_matches_reservation
    return if !keycard || !reservation
    self.errors.add(:base, "The requested key card does not match the reservation's room.") if reservation.room != keycard.room
  end

  def user_can_checkout
    errors.add(:base, "You are unauthorized to check in a key card.") unless user_ability.can?(:check_out, keycard)
  end

  def user_ability
    @user_ability ||= Ability.new(user)
  end
end
