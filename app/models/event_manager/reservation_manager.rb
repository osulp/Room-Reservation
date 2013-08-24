class EventManager::ReservationManager < EventManager::EventManager

  def range_reservations(start_time, end_time)
    Reservation.where("start_time <= ? AND end_time >= ? AND room_id IN (?)", end_time, start_time, rooms)
  end

  def get_events
    events = range_reservations(start_time, end_time).order(:start_time).map{|x| to_event(x)}
  end

  def to_event(reservation)
    ReservationDecorator.new(Event.new(reservation.start_time-reservation_padding, reservation.end_time+reservation_padding, priority, reservation, reservation.room_id))
  end

  # @TODO: Move this into configuration
  def reservation_padding
    10.minutes
  end

  def priority
    0
  end

end