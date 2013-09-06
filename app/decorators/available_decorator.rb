class AvailableDecorator < EventDecorator

  def color
    return 'success'
  end

  def description
    return 'Available'
  end

  def data_hash
    {
        start: (start_time).iso8601.to_s,
        end: (end_time).iso8601.to_s
    }
  end

end