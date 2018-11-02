require 'faraday'

class EventManager::HoursManager < EventManager::EventManager
  def hours(date, rooms=[])
    @hours ||= {}
    return @hours[date] if @hours.has_key?(date)
    result = get_api_hours(date, rooms)
    @hours[date] = result
    return @hours[date]
  end

  ##
  # Fetch the open hours for the date provided
  # @param date [Date] the date to query open hours
  # @param rooms [Array<Room>] an array of rooms
  # @return [Hash] the open hours and the rooms queried
  def get_api_hours(date, rooms)
    body = api_request(date)
    json = JSON.parse(body)
    result = json.keep_if { |k,v| k.start_with?(date.to_s) }.first[1]
    result = fix_api_hours(result)
    result[:rooms] = rooms
    result
  end

  ##
  # The app has some magic built in;
  #  - open&close time of 1am indicates that the Library is closed to all public access.
  #  - open&close time of 12am indicates that the Library is open for 24 hours for public access.
  # @param api_result [Hash] the result from the api call
  # @return [Hash] fixed hash to indicate the library is closed if the api event_status says 'CLOSE'
  def fix_api_hours(api_result)
    api_result['event_status'] ||= ''
    if api_result['event_status'].casecmp('close').zero?
      api_result['open'] = '1:00 am'
      api_result['close'] = '1:00 am'
    elsif !api_result['open_all_day'].blank? && api_result['open_all_day']
      api_result['open'] = '12:00 am'
      api_result['close'] = '12:00 am'
    end
    api_result
  end

  ##
  # Fetch the dates from the API server
  # @param date [String] a string date to query for
  # @return [Response] the response object from the HTTP call
  def api_request(date)
    api_cache_key = "api_request/#{date}"
    if Rails.cache.exist?(api_cache_key)
      result = Rails.cache.read(api_cache_key)
      Rails.logger.debug "#{api_cache_key} found in cache, will not query the api until the cache expires. Cached result returned: #{result}"
      return result
    end
    return Rails.cache.read(api_cache_key) if Rails.cache.exist?(api_cache_key)
    conn = Faraday.new(url: APP_CONFIG["api"]["url"]) do |faraday|
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
    end
    response = conn.post APP_CONFIG["api"]["hours_action"], { dates: [date] }
    Rails.logger.debug "Failed api_request, will not cache: api_request(#{date}) returned #{response.body}" unless response.success?
    Rails.cache.write(api_cache_key, response.body, expires_in: 6.hours) if response.success?
    Rails.logger.debug "Successful api_request, will cache: api_request(#{date}) returned #{response.body}" if response.success?
    response.body
  end

  def specific_room_hours
    return @specific_room_hours if @specific_room_hours
    @specific_room_hours = applicable_room_hours.group_by(&:room_id)
  end

  def applicable_room_hours(start=nil, ending=nil)
    start ||= start_time
    ending ||= end_time
    RoomHourRecord.includes(:room, :room_hour).where("room_hours.start_date <= ? AND room_hours.end_date >= ?", (ending-1.minute).to_date, start.to_date).references(:room_hours)
  end

  def get_events
    date_start = @start_time.to_date
    date_end = (@end_time-1.minute).to_date
    all_events = []
    date_start.upto(date_end) do |date|
      hours = hours(date, rooms)
      all_events |= hours_to_events(hours,date)
    end
    all_events
  end

  def cache_key(start_time, end_time,rooms=[])
    date_start = start_time.to_date
    date_end = (end_time-1.minute).to_date
    hours_cache_key = ""
    date_start.upto(date_end) do |date|
      hours = hours(date, rooms)
      unless hours.blank?
        hours_cache_key += "/#{hours["open"]}/#{hours["close"]}"
      end
    end
    hours_cache_key += "/#{room_hour_cache_key(start_time, end_time)}"
    "#{self.class}#{hours_cache_key}"
  end

  def room_hour_cache_key(start_time, end_time)
    RoomHour.with_deleted.where("start_date <= ? AND end_date >= ?", (end_time-1.minute).to_date, start_time.to_date).order("updated_at DESC").first.try(:cache_key)
  end

  def priority
    1
  end

  private

  def hours_to_events(hours,date)
    events = []
    all_rooms = hours[:rooms] || rooms
    all_rooms.each do |room|
      local_hours = build_room_hours(room) || hours
      events |= EventManager::EventManager::HourEventConverter.new(local_hours, date, room, priority).events
    end
    return events
  end

  def build_room_hours(room)
    room_hours = specific_room_hours[room.id]
    return nil if room_hours.blank?
    room_hours = room_hours.first.room_hour
    open_time = room_hours.start_time.strftime("%l:%M %P")
    close_time = room_hours.end_time.strftime("%l:%M %P")
    return {"open" => open_time, "close" => close_time}
  end

  def self.hour_models
    [
      Hours::Hour,
      Hours::IntersessionHour,
      Hours::SpecialHour
    ].sort_by(&:priority).reverse!
  end
end
