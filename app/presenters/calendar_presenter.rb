class CalendarPresenter
  include Enumerable
  def initialize(room, start_time, end_time, *managers)
    @object = room
    @start_time = start_time
    @end_time = end_time
    @managers = managers
  end

  def each
    return enum_for(:each) unless block_given?
    event_collection.each do |event|
      yield event
    end
  end

  def event_collection(force=false)
    return @event_collection unless @event_collection.blank? || force
    @event_collection = @managers.map{|m| m.events_between(@start_time, @end_time, @room)}
                                 .flatten
                                 .sort_by(&:start_time)
    fix_event_collisions! @event_collection
    return @event_collection
  end

  private

  def fix_event_collisions! (event_collection)
    event_collection.each do |event|
      next unless event.valid?
      event_collection.each do |event_2|
        next if event == event_2
        next unless event_2.valid?
        collide(event, event_2)
      end
    end
    event_collection.delete_if{|event| !event.valid?}
  end

  def collide(event, event_2)
    if event.start_time <= event_2.start_time && event_2.start_time <= event.end_time
      if event.priority >= event_2.priority
        event_2.start_time = event.end_time
      else
        event.end_time = event_2.start_time
      end
    end
  end
end
