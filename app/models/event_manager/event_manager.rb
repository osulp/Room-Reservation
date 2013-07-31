class EventManager::EventManager

  attr_accessor :room, :start_time, :end_time
  def initialize(room=nil)
    @room = room
  end

  def events_between(start_time, end_time)
    @start_time, @end_time = start_time, end_time
    raise "Invalid parameters" unless self.valid?
    return get_events
  end


  def valid?
    true
  end

  def get_events
    raise "get_events not implemented"
  end
end