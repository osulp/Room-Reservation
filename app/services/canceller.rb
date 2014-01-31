class Canceller
  include ActiveModel::Validations
  # Callbacks
  define_model_callbacks :reservation_destroy
  attr_accessor :reservation, :cancelling_user
  validate :reservation_owned_by_user
  validate :reservation_not_over
  validate :reservation_not_checked_out

  delegate :as_json, :to => :reservation
  after_reservation_destroy :send_email
  before_reservation_destroy :checkin_keycard

  def initialize(reservation, cancelling_user)
    self.reservation = reservation
    self.cancelling_user = cancelling_user
  end

  def save
    return false unless valid?
    run_callbacks :reservation_destroy do
      reservation.destroy
    end
  end

  protected

  def checkin_keycard
    if reservation.key_card
      service = Keycards::CheckinService.new(reservation.key_card, cancelling_user)
      service.save
    end
  end

  def send_email
    reserved_for = UserDecorator.new(User.new(reservation.user_onid))
    reserved_for = cancelling_user if reserved_for.onid == cancelling_user.onid
    unless reserved_for.email.blank?
      ReservationMailer.delay.cancellation_email(reservation, reserved_for)
    end
  end

  def reservation_owned_by_user
    errors.add(:base, "Unauthorized for cancellation of this reservation") unless cancelling_user_ability.can?(:destroy, reservation)
  end

  def reservation_not_over
    time = reservation.truncated_at if reservation.truncated_at < reservation.end_time && reservation.truncated_at > reservation.start_time
    time ||= [reservation.start_time, reservation.end_time].max
    errors.add(:base, "Completed reservations may not be cancelled") if time  < Time.current
  end

  def reservation_not_checked_out
    errors.add(:reservation, "can not be cancelled while it is checked out.") if reservation.key_card && !cancelling_user_ability.can?(:ignore_restrictions, self.class)
  end

  def cancelling_user_ability
    @cancelling_user_ability ||= Ability.new(cancelling_user)
  end

end
