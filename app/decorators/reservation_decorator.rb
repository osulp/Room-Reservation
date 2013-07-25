class ReservationDecorator < Draper::Decorator
  delegate_all

  def bar_length
    @bar_length ||= convert_to_pixels self.duration
  end

  def bar_start
    @bar_start ||= convert_to_pixels self.start_time.seconds_since_midnight
  end

  def bar_end
    @bar_end ||= convert_to_pixels self.end_time.seconds_since_midnight
  end

  def color
    return 'danger' if self.user_onid == '_schedule' || self.user_onid == '_maintainance'
    return 'info' if self.user_onid == 'luxi' #current_user.name
    return 'warning'
  end


  private
  def convert_to_pixels time
    time / 180
  end

end
