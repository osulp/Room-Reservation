class HoursDecorator < EventDecorator

  def color
    return 'danger'
  end

  def description
    "Closed"
  end

end
