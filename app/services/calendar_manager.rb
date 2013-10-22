class CalendarManager
  attr_reader :day

  def initialize(date=Time.current.to_date)
    @day = Time.zone.local(date.year,date.month,date.day)
  end
end
