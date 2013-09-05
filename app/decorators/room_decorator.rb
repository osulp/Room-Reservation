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
    last_bar_end = 0
    events.each do |event|
      if event.bar_start > last_bar_end
        start_time = event.start_time.midnight+(last_bar_end*180).seconds
        end_time = event.start_time
        @decorated_events << build_available_decorator(start_time, end_time)
      end
      last_bar_end = event.bar_end
      @decorated_events << event
    end
    if 480 > last_bar_end.to_i+1
      start_time = Time.current.midnight+(last_bar_end*180).seconds
      end_time = Time.current.tomorrow.midnight
      @decorated_events << build_available_decorator(start_time, end_time)
    end
    return @decorated_events
  end

  def build_available_decorator(start_time, end_time)
    AvailableDecorator.new(Event.new(start_time, end_time, 0))
  end

end
