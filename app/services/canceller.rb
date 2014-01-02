class Canceller
  include ActiveModel::Validations
  # Callbacks
  define_model_callbacks :reservation_destroy
  attr_accessor :reservation, :cancelling_user
  validate :reservation_owned_by_user
  validate :reservation_not_over

  delegate :as_json, :to => :reservation
  after_reservation_destroy :send_email

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
    errors.add(:base, "Completed reservations may not be cancelled") if [reservation.start_time, reservation.end_time].max < Time.current
  end

  def cancelling_user_ability
    @cancelling_user_ability ||= Ability.new(cancelling_user)
  end

end
