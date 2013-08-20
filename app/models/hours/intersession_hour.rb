class Hours::IntersessionHour < ActiveRecord::Base
  establish_connection "drupal_#{Rails.env}"
  self.table_name = 'int_hours'
  # @param dates [Array<Date>] Array of dates you want the hours for.
  # @return [Hash<Hash>] Hash where each key is the date with the hours containing a hash with an "open" and "close" key representing the close/open time.
  # @note This function must be named the same in Hour, SpecialHour and IntersessionHour for HourManager to work.
  def self.time_info(dates)
    dates = Array.wrap(dates)
    result = {}
    allHours = all
    dates.each do |date|
      next unless date.instance_of? Date
      hours = allHours.select{|x| x.start_date.to_date <= date && x.end_date.to_date >= date}[0]
      next unless hours
      suffix = 'wk'
      if date.wday == 6
        suffix = 'sat'
      end
      if date.wday == 0
        suffix = 'sun'
      end
      openTime = hours["open_time_#{suffix}"]
      closeTime = hours["close_time_#{suffix}"]
      openTime = Time.zone.parse("#{date} #{openTime.hour}:#{openTime.min}:#{openTime.sec}").strftime("%l:%M %P").strip
      closeTime = Time.zone.parse("#{date} #{closeTime.hour}:#{closeTime.min}:#{closeTime.sec}").strftime("%l:%M %P").strip
      result[date] = {'open' => openTime, 'close' => closeTime}
    end
    return result
  end

  def self.priority
    1
  end
end