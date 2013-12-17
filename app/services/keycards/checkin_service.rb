class Keycards::CheckinService
  include ActiveModel::Model
  attr_accessor :keycard, :user
  validate :user_can_checkin
  validate :append_keycard_errors
  validate :append_reservation_errors

  def initialize(keycard, user)
    self.keycard = keycard
    self.user = user
  end

  def user=(user)
    if user.kind_of?(String)
      user = User.new(user)
    end
    @user = user
  end

  def save
    truncate_reservation
    reservation = keycard.reservation
    remove_reservation
    return false unless valid?
    KeyCard.transaction do
      result = keycard.save
      result &&= Reserver.new(reservation).save if reservation
      raise ActiveRecord::Rollback unless result == true
    end
    return true
  end

  private

  # @TODO: Add truncated_at timestamp.
  def truncate_reservation
    keycard.reservation.end_time = Time.current if keycard.reservation
  end

  def remove_reservation
    keycard.reservation = nil
  end

  def append_keycard_errors
    return if !keycard
    unless keycard.valid?
      keycard.errors.full_messages.each do |msg|
        self.errors.add(:base, msg)
      end
    end
  end

  def append_reservation_errors
    return if !keycard.reservation
    unless keycard.reservation.valid?
      keycard.reservation.errors.full_messages.each do |msg|
        self.errors.add(:base, msg)
      end
    end
  end

  def user_can_checkin
    errors.add(:base, "You are unauthorized to check in a key card.") unless user_ability.can?(:check_in, keycard)
  end

  def user_ability
    @user_ability ||= Ability.new(user)
  end
end
