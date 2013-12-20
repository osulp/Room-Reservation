class EventManager::ReservationManager < EventManager::EventManager

  def cache_key(start_time, end_time,rooms=[])

    "#{self.class}/#{start_time.to_i}/#{end_time.to_i}/#{reservation_cache_key(start_time, end_time)}"
  end

  def reservation_cache_key(start_time, end_time)
    Reservation.with_deleted.where("start_time <= ? AND end_time >= ?", end_time, start_time).order("updated_at DESC").first.try(:cache_key)
  end

  def range_reservations(start_time, end_time)
    Reservation.where("start_time <= ? AND end_time >= ? AND room_id IN (?)", end_time, start_time, rooms)
  end

  def get_events
    events = range_reservations(start_time, end_time).order(:start_time).map{|x| to_event(x)}
  end

  def to_event(reservation)
    ReservationDecorator.new(Event.new(reservation.start_time-reservation_padding, (reservation.truncated_at || reservation.end_time)+reservation_padding, priority, reservation, reservation.room_id))
  end

  # @TODO: Move this into configuration
  def reservation_padding
    10.minutes
  end

  def priority
    0
  end

end