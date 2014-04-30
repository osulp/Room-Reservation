class Events::CleaningEvent < Event
  def color
    return 'danger'
  end

  def description
    "Closed"
  end

  def payload
    @payload ||= small_payload
  end

  protected

  def small_payload
    @small_payload ||= Events::Payload.new({
      :id => payload.id,
      :start_date => payload.start_date,
      :end_date => payload.end_date,
      :class_name => payload.class,
      :start_time => payload.start_time,
      :end_time => payload.end_time,
      :weekdays => payload.weekdays
    })
  end


  # Marshalling to avoid building huge payload object.
  def marshal_dump
    [start_time, end_time, priority, room_id, small_payload]
  end
  def marshal_load(array)
    @start_time, @end_time, @priority, @room_id, @small_payload = array
  end
end
