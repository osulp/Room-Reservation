class EventManager::HoursManager < EventManager::EventManager
  def hours(date)
    @hours ||= {}
    return @hours[date] if @hours.has_key?(date)
    result = {}
    result = get_drupal_hours(date)
    @hours[date] = result
    return @hours[date]
  end

  def get_drupal_hours(date)
    result = {}
    self.class.hour_models.each do |hour_model|
      result = hour_model.time_info(date)
      result = result[date] unless result.blank?
      break unless result.blank?
    end
    result[:rooms] = @rooms unless result.blank?
    return result
  end

  def get_events
    date_start = @start_time.to_date
    date_end = (@end_time-1.minute).to_date
    all_events = []
    date_start.upto(date_end) do |date|
      hours = hours(date)
      next if hours["open"] == midnight &&  hours["close"] == midnight
      all_events |= hours_to_events(hours,date)
    end
    all_events
  end

  def cache_key(start_time, end_time)
    date_start = start_time.to_date
    date_end = (end_time-1.minute).to_date
    hours_cache_key = ""
    date_start.upto(date_end) do |date|
      hours = hours(date)
      unless hours.blank?
        hours_cache_key += "/#{hours["open"]}/#{hours["close"]}"
      end
    end
    "#{self.class}#{hours_cache_key}"
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
    start_at = date.at_beginning_of_day
    end_at = (date+1.day).at_beginning_of_day
    events = []
    unless hours.blank? || (hours["open"] == one && hours["close"] == one)
      unless hours["open"] == special
        start_at = date.at_beginning_of_day
        end_at = string_to_time(date, hours["open"])
        hours[:rooms].each do |room|
          events << build_event(start_at, end_at, room)
        end
      end
      unless hours["close"] == special
        start_at = string_to_time(date, hours["close"])
        end_at = (date+1.day).at_beginning_of_day
        hours[:rooms].each do |room|
          events << build_event(start_at, end_at, room)
        end
      end
    else
      @rooms.each do |room|
        events << build_event(start_at, end_at, room)
      end
    end
    return events
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
