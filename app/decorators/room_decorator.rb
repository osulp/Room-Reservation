class RoomDecorator < Draper::Decorator
  delegate_all
  attr_accessor :events

  def filter_string
    string = ""
    filters.each do |filter|
      string += "filter-#{filter.id} "
    end
    string.strip
  end

  def decorated_events
    return @decorated_events if @decorated_events
    @decorated_events = []
    last_start_time = Time.current.midnight.seconds_since_midnight
    events.each do |event|
      if event.start_time.seconds_since_midnight > last_start_time
        start_time = event.start_time.midnight+last_start_time.seconds
        end_time = event.start_time
        @decorated_events << build_available_decorator(start_time, end_time)
      end
      last_start_time = event.end_time.seconds_since_midnight
      @decorated_events << event
    end
    if events.length == 0 || last_start_time != 0
      start_time = Time.current.midnight+last_start_time.seconds
      end_time = Time.current.tomorrow.midnight
      @decorated_events << build_available_decorator(start_time, end_time)
    end
    return @decorated_events
  end

  def build_available_decorator(start_time, end_time)
    AvailableDecorator.new(Event.new(start_time, end_time, 0))
  end

end
