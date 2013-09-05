class AvailableDecorator < EventDecorator

  def color
    return 'success'
  end

  def description
    return 'Available'
  end

  def data_hash
    {
        start: (start_time).to_s,
        end: (end_time).to_s
    }
  end

end