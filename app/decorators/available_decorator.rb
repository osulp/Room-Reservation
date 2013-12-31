class AvailableDecorator < EventDecorator

  def color
    return 'success'
  end

  def description
    return 'Click to Reserve'
  end

  def data_hash
    {
        start: (start_time).iso8601.to_s,
        end: (end_time).iso8601.to_s,
        action: "reserve"
    }
  end

end