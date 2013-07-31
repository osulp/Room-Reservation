class EventManager::ReservationManager < EventManager::EventManager

  def get_events
    events = room.reservations.where("start_time <= ? AND end_time >= ?", end_time, start_time).order(:start_time).map{|x| to_event(x)}
  end

  def to_event(reservation)
    Event.new(reservation.start_time-reservation_padding, reservation.end_time+reservation_padding, priority, reservation)
  end

  # @TODO: Move this into configuration
  def reservation_padding
    10.minutes
  end

  def priority
    0
  end

  def valid?
    return false unless room
    return false unless room.kind_of?(Room)
    true
  end

end