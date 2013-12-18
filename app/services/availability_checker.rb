class AvailabilityChecker
  attr_reader :room, :start_time, :end_time, :blacklist

  def initialize(room, start_time, end_time, blacklist=[])
    @room = room
    @start_time = start_time
    @end_time = end_time
    @blacklist = blacklist
  end
  def available?
    return false unless events.empty?
    true
  end

  def events
    return @events if @events
    @events = []
    start_date = start_time.to_date
    end_date = (end_time-1.minute).to_date
    start_date.upto(end_date) do |date|
      time = Time.zone.parse(date.to_s)
      presenter = CalendarPresenter.cached(time, time.tomorrow.midnight)
      @events |= presenter.rooms.find{|room| room.id == self.room.id}.events
    end
    @events = @events.select{|event| event.end_time > start_time && event.start_time < end_time && event.try(:object).try(:payload) != blacklist}
    @events
  end
end
