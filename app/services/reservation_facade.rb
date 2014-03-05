class ReservationFacade
  attr_accessor :user, :current_user
  def initialize(user, current_user=nil)
    self.user = user
    self.current_user = current_user || user
  end

  def reservations
    # Split all reservations into coming ones and invalid ones
    reservations = []
    reservations[0] = decorator.decorate_collection(user.reservations.with_deleted.where("end_time >= ? AND truncated_at IS NULL AND deleted_at IS NULL", Time.current).order(:start_time).decorate)
    reservations[1] = decorator.decorate_collection(user.reservations.with_deleted.where("end_time < ? OR truncated_at IS NOT NULL OR deleted_at IS NOT NULL", Time.current).order("start_time DESC"))
    #reservations = user.reservations.with_deleted.order(:start_time).partition do |r|
    #  r.end_time.future? && !r.deleted? && r.truncated_at.blank?
    #end
    # TODO: Cache this if necessary; Slice this if it's too long
    #reservations[1].reverse!
    #return reservations.map{|x| x.map{|y| decorator.new(y)}}
    return reservations
  end

  private

  def decorator
    return AdminReservationDecorator if current_user.staff?
    ReservationDecorator
  end
end
