class EventManager::EventManager

  attr_accessor :rooms, :start_time, :end_time
  def initialize(rooms=nil)
    @rooms = rooms
  end

  def events_between(start_time, end_time, rooms=nil)
    return @events if @events
    @rooms = rooms if rooms
    @start_time, @end_time = start_time, end_time
    raise "Invalid parameters" unless self.valid?
    @events = get_events
  end


  def valid?
    true
  end

  def get_events
    raise "get_events not implemented"
  end
end