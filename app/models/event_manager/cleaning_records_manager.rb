class EventManager::CleaningRecordsManager < EventManager::EventManager

  def valid?
    true
  end

  def get_events
    range_cleaning_records(start_time, end_time).map{|x| to_event(x)}.flatten
  end

  def cache_key(start_time, end_time,rooms=[])
    "#{self.class}/#{start_time.to_i}/#{end_time.to_i}/#{CleaningRecord.with_deleted.where("start_date <= ? AND end_date >= ?", end_time.to_date, start_time.to_date).order("updated_at DESC").first.try(:cache_key)}"
  end

  private

  def range_cleaning_records(start_time, end_time)
    return @range_cleaning_records if @range_cleaning_records
    cleaning_record_rooms = CleaningRecordRoom.where(:room_id => rooms.map(&:id)).pluck(:cleaning_record_id)
    @range_cleaning_records ||= CleaningRecord.where("start_date <= ? AND end_date >= ? AND id IN (?)", (end_time-1.minute).to_date, start_time.to_date, cleaning_record_rooms).includes(:rooms)
  end

  def to_event(cleaning_record)
    result = []
    cleaning_record.rooms.each do |room|
      if rooms.include?(room) && cleaning_record.weekdays.include?(start_time.wday)
        result << CleaningDecorator.new(Event.new(to_time(cleaning_record.start_time, @start_time), to_time(cleaning_record.end_time, (@end_time-1.minute)), priority, cleaning_record, room.id))
      end
    end
    result
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
