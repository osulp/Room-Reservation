class ReservationDecorator < EventDecorator

  def color
    return 'danger'
  end

  def data_hash
    {
        :id => self.id,
        start: (payload.start_time).iso8601.to_s,
        end: (payload.end_time).iso8601.to_s
    }
  end

end
