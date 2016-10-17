class Hours::Hour < ApplicationRecord
  establish_connection :"drupal_#{Rails.env}"
  # @param dates [Array<Date>] Array of dates you want the hours for.
  # @return [Hash<Hash>] Hash where each key is the date with the hours containing a hash with an "open" and "close" key representing the close/open time.
  # @note This function must be named the same in Hour, SpecialHour and IntersessionHour for HourManager to work.
  def self.time_info(dates)
    dates = Array.wrap(dates)
    result = {}
    allHours = where(:loc => APP_CONFIG["hours"]["key_name"])
    dates.each do |date|
      next unless date.instance_of? Date
      hours = allHours.select{|x| x.term_start_date.utc.to_date <= date && x.term_end_date.utc.to_date >= date}[0]
      next unless hours
      wDay = date.wday < 5 ? 1 : date.wday
      if date.wday == 0
        wDay = 7
      end
      openTime = Time.zone.parse("#{date} #{hours["open_time_#{wDay}"]}").strftime("%l:%M %P")
      closeTime = Time.zone.parse("#{date} #{hours["close_time_#{wDay}"]}").strftime("%l:%M %P")
      result[date] = {'open' => openTime.strip, 'close' => closeTime.strip}
    end
    return result
  end

  def self.priority
    0
  end
end
