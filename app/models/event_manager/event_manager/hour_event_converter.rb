class EventManager::EventManager
  class HourEventConverter
    attr_accessor :hour, :date, :room, :priority
    def initialize(hour, date, room, priority)
      @date = date
      @hour = hour
      @room = room
      @priority = priority
    end

    def events
      events = []
      return events if open_all_day?
      return [all_day_closed_event] if closed_all_day?
      events << beginning_of_day_event if closed_at_beginning_of_day?
      events << end_of_day_event if closes_at_end_of_day?
      events.compact
    end

    def all_day_closed_event
      build_event(default_start_at, default_end_at, room)
    end

    def beginning_of_day_event
        start_at = date.at_beginning_of_day
        end_at = string_to_time(date, hour["open"])
        build_event(start_at, end_at, room)
    end

    def end_of_day_event
      # During dead week the hours say they "close" at 1 AM. Lies, but still.
      # TODO: Find a way to add extra 1 hour the next day.
      if hour["close"] == one
        return nil
      end
      start_at = string_to_time(date, hour["close"])
      end_at = (date+1.day).at_beginning_of_day
      build_event(start_at, end_at, room)
    end


    def closed_at_beginning_of_day?
      hour["open"] != special
    end

    def closes_at_end_of_day?
      hour["close"] != special
    end

    def open_all_day?
      hour["open"] == midnight && hour["close"] == midnight
    end

    def closed_all_day?
      hour.blank? || hour["open"] == one && hour["close"] == one
    end

    def default_start_at
      date.at_beginning_of_day
    end

    def default_end_at
      (date+1.day).at_beginning_of_day
    end

    def midnight
      "12:00 am"
    end

    def one
      "1:00 am"
    end

    def special
      "12:15 am"
    end

    def string_to_time(date, time)
      Time.zone.parse("#{date} #{time}")
    end

    def build_event(start_time, end_time, room)
      if (start_time.hour + start_time.min + start_time.sec) != 0
        start_time -= hour_buffer
      end
      Events::HourEvent.new(start_time, end_time, priority, nil, room.id)
    end

    def self.hour_buffer
      Setting.reservation_padding.to_i.minutes
    end

    # TODO: Make this configurable
    def hour_buffer
      self.class.hour_buffer
    end
  end
end
