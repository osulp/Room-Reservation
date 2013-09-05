class ReservationDecorator < EventDecorator

  def color
    return 'danger'
  end

  def data_hash
    {
        :id => self.id
    }
  end

end
