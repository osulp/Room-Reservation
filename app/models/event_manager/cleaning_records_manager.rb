class EventManager::CleaningRecordsManager < EventManager::EventManager

  def valid?
    true
  end

  def get_events
    records = range_cleaning_records(start_time, end_time).map{|x| to_event(x)}.flatten

    # Note: after getting the events, add Events::CleaningEvent to fill in the
    # blocks for multiple closing blocks. Given a start_time date, for each
    # room in floors 1, 2 and 5, add a CleaningRecord without persisting
    # it to automatically add a close block for this additional
    # open/close block. This only works for one additional open/close
    # block for now.
    start_date = start_time.strftime('%Y-%m-%d')
    hours_manager = EventManager::HoursManager.new
    open_hours = hours_manager.hours(start_date)
    if open_hours['all_open_hours'].count > 1
      Room.where(floor: [1,2,5]).each do |room|
        tmp_close_time = Time.parse(open_hours['all_open_hours'].first['close']).strftime('%H:%M:%S')
        tmp_open_time = Time.parse(open_hours['all_open_hours'].last['open']).strftime('%H:%M:%S')
        tmp_start_time = Time.zone.parse("#{start_date} #{tmp_close_time}")
        tmp_end_time = Time.zone.parse("#{start_date} #{tmp_open_time}")
        attributes = {id: rand(DateTime.now.to_i), start_date: "#{start_date}", end_date: "#{start_date}", start_time: "#{tmp_start_time}", end_time: "#{tmp_end_time}"}
        cleaning_record = CleaningRecord.new(attributes)
        records << Events::CleaningEvent.new(tmp_start_time, tmp_end_time, 0, cleaning_record, room.id)
      end
    end
    records
  end

  def cache_key(start_time, end_time,rooms=[])
    "#{self.class}/#{start_time.to_i}/#{end_time.to_i}/#{cleaning_record_cache_key(start_time, end_time)}"
  end

  private

  def cleaning_record_cache_key(start_time, end_time)
    CleaningRecord.with_deleted.where("start_date <= ? AND end_date >= ?", end_time.to_date, start_time.to_date).order("updated_at DESC").first.try(:cache_key)
  end

  def range_cleaning_records(start_time, end_time)
    return @range_cleaning_records if @range_cleaning_records
    cleaning_record_rooms = CleaningRecordRoom.where(:room_id => rooms.map(&:id)).pluck(:cleaning_record_id)
    @range_cleaning_records ||= CleaningRecord.where("start_date <= ? AND end_date >= ? AND id IN (?)", (end_time-1.minute).to_date, start_time.to_date, cleaning_record_rooms).includes(:rooms)
  end

  def to_event(cleaning_record)
    result = []
    cleaning_record.rooms.each do |room|
      if rooms.include?(room) && cleaning_record.weekdays.map{|x| x.to_s}.include?(start_time.wday.to_s)
        result << Events::CleaningEvent.new(to_time(cleaning_record.start_time, @start_time), to_time(cleaning_record.end_time, (@end_time-1.minute)), priority, cleaning_record, room.id)
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
