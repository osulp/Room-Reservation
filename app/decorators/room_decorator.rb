class RoomDecorator < Draper::Decorator
  delegate_all
  attr_accessor :events

  def filter_string
    return @filter_string unless @filter_string.blank?
    string = ""
    filters.each do |filter|
      string += "filter-#{filter.id} "
    end
    @filter_string = string.strip
  end


  # This returns the room's events but with filler "available" events to allow for
  # easier iteration in the views.
  # @TODO Refactor this into something more readable.
  def decorated_events(base_time)
    return @decorated_events if @decorated_events
    @decorated_events = []
    last_start_time = base_time.midnight.seconds_since_midnight
    events.each do |event|
      # Prefix with an 'available' event if required.
      if event.start_time.seconds_since_midnight > last_start_time
        start_time = event.start_time.midnight+last_start_time.seconds
        end_time = event.start_time
        @decorated_events << build_available_decorator(start_time, end_time)
      end
      last_start_time = event.end_time.seconds_since_midnight
      @decorated_events << event
    end
    # Suffix with an 'available' event if necessary
    if events.length == 0 || last_start_time != 0
      start_time = base_time.midnight+last_start_time.seconds
      end_time = base_time.tomorrow.midnight
      @decorated_events << build_available_decorator(start_time, end_time)
    end
    return @decorated_events
  end

  def build_available_decorator(start_time, end_time)
    AvailableDecorator.new(Event.new(start_time, end_time, 0))
  end

  def marshal_dump
    [@filter_string, @decorated_events, object]
  end

  def marshal_load(arr)
    @filter_string, @decorated_events, @object = arr
    @events = @decorated_events.select{|x| !x.kind_of?(AvailableDecorator)}
  end

  def popover_content
    content = ''

    content += h.link_to h.image_tag(image.url, :class => 'room-image'), image.url, :target => '_blank' unless image.blank?
    content += h.simple_format description
    content += h.link_to 'View floor map', floor_map.url, :target => '_blank', :class => 'btn btn-default' unless floor_map.blank?

    content
  end

end
