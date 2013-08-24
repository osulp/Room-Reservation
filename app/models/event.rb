class Event
  include ActiveModel::Validations

  attr_accessor :start_time, :end_time, :priority, :room_id
  attr_reader :payload
  validate :start_time_valid
  def initialize start_time, end_time, priority, payload = nil, room_id = nil
    @start_time = start_time
    @end_time = end_time
    @priority = priority
    @payload = payload
    @room_id = room_id
  end

  def start_time_valid
    errors.add(:start_time, "must be less than end time") unless start_time < end_time
  end

  def duration
    end_time - start_time
  end

  def respond_to_missing?(sym, include_private = false)
    if @payload.nil?
      return super
    else
      @payload.respond_to?(sym, include_private)
    end
  end

  def method_missing(m, *args, &block)
    if @payload.nil?
      return super
    else
      @payload.send(m, *args, &block)
    end
  end
end