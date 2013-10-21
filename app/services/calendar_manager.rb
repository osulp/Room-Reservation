class CalendarManager
  attr_reader :day

  def self.from_string(date_string)
    date = date_string.to_date
    return self.new({:year => date.year, :month => date.month, :day => date.day})
  end

  def initialize(opts={})
    # TODO: Patch CookieJar in Rails to allow for values_at.
    day = opts[:day].to_i
    month = opts[:month].to_i
    year = opts[:year].to_i
    @day = Time.current.midnight
    @day = Time.zone.local(year,month,day) unless (day.blank? || month.blank? || year.blank? || (day+month+year)==0)
  end
end
