class ReservationFacade
  attr_accessor :user
  def initialize(user)
    self.user = user
  end

  def reservations
    # Split all reservations into coming ones and invalid ones
    reservations = user.reservations.with_deleted.order(:start_time).partition do |r|
      r.end_time.future? && !r.deleted? && r.truncated_at.blank?
    end
    # TODO: Cache this if necessary; Slice this if it's too long
    reservations[1].reverse!
    reservations.map!{|x| x.map{|y| y.decorate}}
    return reservations
  end
end