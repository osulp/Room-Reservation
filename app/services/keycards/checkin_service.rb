class Keycards::CheckinService
  include ActiveModel::Model
  attr_accessor :keycard, :user, :reservation
  validate :user_can_checkin
  validate :append_keycard_errors
  validate :append_reservation_errors
  validate :has_reservation

  def initialize(keycard, user)
    self.keycard = keycard
    self.user = user
    self.reservation = keycard.reservation
  end

  def user=(user)
    if user.kind_of?(String)
      user = User.new(user)
    end
    @user = user
  end

  def save
    if reservation
      old_start = reservation.start_time
      old_end = reservation.end_time
    end
    truncate_reservation
    remove_reservation
    return false unless valid?
    KeyCard.transaction do
      result = keycard.save
      result &&= Reserver.new(reservation).save if reservation
      raise ActiveRecord::Rollback unless result == true
    end
    notify_dates(old_start, old_end) if reservation
    return true
  end

  def notify_dates(start_time, end_time)
    CalendarPresenter.publish_changed(start_time, end_time)
  end

  def attributes
    {"keycard" => nil}
  end

  def as_json(options={})
    {"keycard" => keycard}
  end

  private

  # @TODO: Add truncated_at timestamp.
  def truncate_reservation
    return if !reservation
    #return if reservation.end_time < Time.current
    #return if reservation.start_time > Time.current
    reservation.truncated_at = Time.current
  end

  def remove_reservation
    keycard.reservation = nil
    reservation.key_card = nil if reservation
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
    return if !reservation
    unless reservation.valid?
      reservation.errors.full_messages.each do |msg|
        self.errors.add(:base, msg)
      end
    end
  end

  def has_reservation
    errors.add(:base, "Not checked out.") unless reservation
  end

  def user_can_checkin
    errors.add(:base, "You are unauthorized to check in a key card.") unless user_ability.can?(:check_in, keycard)
  end

  def user_ability
    @user_ability ||= Ability.new(user)
  end
end
