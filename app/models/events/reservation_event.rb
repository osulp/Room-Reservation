class Events::ReservationEvent < Event

  def initialize(*args)
    super
    @payload = small_payload
  end
  
  def color
    return 'danger'
  end

  def description
    payload.description
  end

  def data_hash
    {
        :id => payload.id,
        start: (payload.start_time).iso8601.to_s,
        end: (payload.end_time).iso8601.to_s,
        user_onid: payload.user_onid
    }
  end

  def payload
    @payload ||= small_payload
  end

  protected

  def small_payload
    @small_payload ||= Events::Payload.new({
      :id => payload.id,
      :start_time => payload.start_time,
      :end_time => payload.end_time,
      :user_onid => payload.user_onid,
      :description => payload.description,
      :class_name => payload.class
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
