class ReservationDecorator < EventDecorator

  def color
    return 'danger'
  end

  def formatted_start
    start_time.strftime("%m/%d %l:%M %p")
  end

  def formatted_end
    end_time.strftime("%l:%M %p")
  end

  def formatted_deleted_at
    deleted_at.strftime("%m/%d %l:%M %p")
  end

  def formatted_created_at
    created_at.strftime("%m/%d %l:%M %p")
  end

  def payload
    if object.respond_to?(:payload)
      object.payload
    else
      self
    end
  end

  def data_hash
    {
        :id => self.id,
        start: (payload.start_time).iso8601.to_s,
        end: (payload.end_time).iso8601.to_s
    }
  end

end
