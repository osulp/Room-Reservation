class EventManager::CleaningRecordsManager < EventManager::EventManager

  def valid?
    return false unless room
    return false unless room.kind_of?(Room)
    true
  end

  def get_events
    range_cleaning_records(start_time, end_time).map{|x| to_event(x)}
  end

  # Expires caches that would have to do with cleaning record.
  def self.expire_cache(cleaning_record_room, cleaning_record)
    start_date = cleaning_record.start_date.to_date
    end_date = cleaning_record.end_date.to_date
    expire_range(start_date, end_date, cleaning_record_room.room)
    # Expire old range in case it changed.
    start_date = cleaning_record.start_date_was.try(:to_date)
    end_date = cleaning_record.end_date_was.try(:to_date)
    expire_range(start_date, end_date, cleaning_record_room.room) if start_date && end_date
  end

  def self.expire_range(start_date, end_date, room)
    start_date.upto(end_date) do |date|
      start_time = Time.zone.parse(date.to_s)
      end_time = Time.zone.parse((date+1.day).to_s)
      key = self.cache_key(start_time, end_time, room)
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
    @cache_key ||= Rails.cache.fetch(self.class.cache_key(start_time, end_time, room)) do
     self.class.form_cache_key(start_time, end_time, room)
    end
  end

  private

  def range_cleaning_records(start_time, end_time)
    @range_cleaning_records ||= room.cleaning_records.where("start_date <= ? AND end_date >= ?", end_time.to_date, start_time.to_date)
  end

  def to_event(cleaning_record)
    CleaningDecorator.new(Event.new(to_time(cleaning_record.start_time, @start_time), to_time(cleaning_record.end_time, (@end_time-1.minute)), priority, cleaning_record))
  end

  def to_time(time, date)
    date = date.to_date
    time = time.utc
    Time.zone.parse("#{date} #{time.hour}:#{time.min}:#{time.sec}")
  end

  # TODO: Might want to change this - we'll see.
  def priority
    0
  end
end
