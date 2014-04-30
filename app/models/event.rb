class Event
  include ActiveModel::Validations
  include Events::Concerns::ViewLogic

  attr_accessor :start_time, :end_time, :priority, :room_id
  attr_reader :payload
  def initialize start_time, end_time, priority, payload = nil, room_id = nil
    @start_time = start_time
    @end_time = end_time
    @priority = priority
    @payload = payload
    @room_id = room_id
  end

  def valid?
    return false unless start_time < end_time
    true
  end

  def duration
    end_time - start_time
  end

end
