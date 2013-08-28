class EventManager::HoursManager < EventManager::EventManager
  def hours(date, rooms=[])
    @hours ||= {}
    return @hours[date] if @hours.has_key?(date)
    result = get_drupal_hours(date, rooms)
    @hours[date] = result
    return @hours[date]
  end

  def get_drupal_hours(date, rooms)
    result = {}
    self.class.hour_models.each do |hour_model|
      result = hour_model.time_info(date)
      result = result[date] unless result.blank?
      unless result.blank?
        result[:rooms] = rooms
        break
      end
    end
    return result
  end

  def specific_room_hours
    return @specific_room_hours if @specific_room_hours
    @specific_room_hours = applicable_room_hours.group_by(&:room_id)
  end

  def applicable_room_hours(start=nil, ending=nil)
    start ||= start_time
    ending ||= end_time
    RoomHourRecord.includes(:room, :room_hour).where("room_hours.start_date <= ? AND room_hours.end_date >= ?", (ending-1.minute).to_date, start.to_date)
  end

  def get_events
    date_start = @start_time.to_date
    date_end = (@end_time-1.minute).to_date
    all_events = []
    date_start.upto(date_end) do |date|
      hours = hours(date, rooms)
      all_events |= hours_to_events(hours,date)
    end
    all_events
  end

  def cache_key(start_time, end_time,rooms=[])
    date_start = start_time.to_date
    date_end = (end_time-1.minute).to_date
    hours_cache_key = ""
    date_start.upto(date_end) do |date|
      hours = hours(date, rooms)
      unless hours.blank?
        hours_cache_key += "/#{hours["open"]}/#{hours["close"]}"
      end
    end
    hours_cache_key += "/#{room_hour_cache_key(start_time, end_time)}"
    "#{self.class}#{hours_cache_key}"
  end

  def room_hour_cache_key(start_time, end_time)
    RoomHour.where("start_date <= ? AND end_date >= ?", (end_time-1.minute).to_date, start_time.to_date).order("updated_at DESC").first.try(:cache_key)
  end

  def priority
    1
  end

  private

  def midnight
    "12:00 am"
  end

  def one
    "1:00 am"
  end

  def special
    "12:15 am"
  end

  def hours_to_events(hours,date)
    default_start_at = date.at_beginning_of_day
    default_end_at = (date+1.day).at_beginning_of_day
    events = []
    all_rooms = hours[:rooms] || rooms
    all_rooms.each do |room|
      local_hours = build_room_hours(room) || hours
      next if local_hours["open"] == midnight && local_hours["close"] == midnight
      unless local_hours.blank? || (local_hours["open"] == one && local_hours["close"] == one)
        unless local_hours["open"] == special
          start_at = date.at_beginning_of_day
          end_at = string_to_time(date, local_hours["open"])
          events << build_event(start_at, end_at, room)
        end
        unless local_hours["close"] == special
          start_at = string_to_time(date, local_hours["close"])
          end_at = (date+1.day).at_beginning_of_day
          events << build_event(start_at, end_at, room)
        end
      else
        events << build_event(default_start_at, default_end_at, room)
      end
    end
    return events
  end

  def build_room_hours(room)
    room_hours = specific_room_hours[room.id]
    return nil if room_hours.blank?
    room_hours = room_hours.first.room_hour
    open_time = room_hours.start_time.strftime("%l:%M %P")
    close_time = room_hours.end_time.strftime("%l:%M %P")
    return {"open" => open_time, "close" => close_time}
  end

  def build_event(start_time, end_time, room)
    HoursDecorator.new(Event.new(start_time, end_time, priority, nil, room.id))
  end

  def string_to_time(date, time)
    Time.zone.parse("#{date} #{time}")
  end

  def self.hour_models
    [
        Hours::Hour,
        Hours::IntersessionHour,
        Hours::SpecialHour
    ].sort_by(&:priority).reverse!
  end
end
