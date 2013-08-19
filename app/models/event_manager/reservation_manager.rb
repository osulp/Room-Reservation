class EventManager::ReservationManager < EventManager::EventManager

  # Expires caches that would have to do with this reservation.
  def self.expire_cache(reservation)
    start_date = reservation.start_time.to_date
    end_date = reservation.end_time.to_date
    start_date.upto(end_date) do |date|
      start_time = Time.zone.parse(date.to_s)
      end_time = Time.zone.parse((date+1.day).to_s)
      key = self.cache_key(start_time, end_time, reservation.room)
      Rails.cache.delete(key)
    end
  end

  def self.cache_key(start_time, end_time, room)
    "#{self}/#{start_time.to_i}/#{end_time.to_i}/#{room.cache_key}"
  end

  def self.form_cache_key(start_time, end_time, room)
    "#{self.cache_key(start_time, end_time, room)}/#{SecureRandom.hex}"
  end

  def cache_key(start_time, end_time)
    # TODO: Do some benchmarking when this comes out - it may be more efficient to just blow the whole
    #       cache away every time a new reservation comes in.
    #@cache_item ||= range_reservations(start_time, end_time).order("updated_at DESC").first
    @cache_key ||= Rails.cache.fetch(self.class.cache_key(start_time, end_time, room)) do
      self.class.form_cache_key(start_time, end_time, room)
    end
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