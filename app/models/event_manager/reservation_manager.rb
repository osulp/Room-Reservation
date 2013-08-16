class EventManager::ReservationManager < EventManager::EventManager

  def cache_key(start_time, end_time)
    # TODO: Do some benchmarking when this comes out - it may be more efficient to just blow the whole
    #       cache away every time a new reservation comes in.
    @cache_item ||= range_reservations(start_time, end_time).order("updated_at DESC").first
    #@cache_item = room
    cache_key = "#{self.class}/#{start_time.to_i}/#{end_time.to_i}/#{room.cache_key}"
    cache_key += "/#{@cache_item.cache_key}" if @cache_item
    return cache_key
  end

  def range_reservations(start_time, end_time)
    room.reservations.where("start_time <= ? AND end_time >= ?", end_time, start_time)
  end

  def get_events
    events = range_reservations(start_time, end_time).order(:start_time).map{|x| to_event(x)}
  end

  def to_event(reservation)
    ReservationDecorator.new(Event.new(reservation.start_time-reservation_padding, reservation.end_time+reservation_padding, priority, reservation))
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