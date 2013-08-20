class Hours::SpecialHour < ActiveRecord::Base
  establish_connection "drupal_#{Rails.env}"
  self.table_name = "special_hours"
  def self.time_info(dates)
    dates = Array.wrap(dates)
    result = {}
    allHours = all
    dates.each do |date|
      next unless date.instance_of? Date
      hours = allHours.select{|x| x.start_date.utc.to_date <= date && x.end_date.utc.to_date >= date}[0]
      next unless hours
      openTime = hours['open_time']
      closeTime = hours['close_time']
      openTime = Time.zone.parse("#{date} #{openTime.hour}:#{openTime.min}:#{openTime.sec}").strftime("%l:%M %P").strip
      closeTime = Time.zone.parse("#{date} #{closeTime.hour}:#{closeTime.min}:#{closeTime.sec}").strftime("%l:%M %P").strip
      result[date] = {'open' => openTime, 'close' => closeTime}
    end
    return result
  end

  def self.priority
    2
  end
end