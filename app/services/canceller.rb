class Canceller
  include ActiveModel::Validations

  attr_accessor :reservation, :cancelling_user
  validate :reservation_owned_by_user
  validate :reservation_not_over

  delegate :as_json, :to => :reservation

  def initialize(reservation, cancelling_user)
    self.reservation = reservation
    self.cancelling_user = cancelling_user
  end

  def save
    return false unless valid?
    return reservation.destroy
  end

  protected

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
