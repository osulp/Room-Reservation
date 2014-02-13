class UpcomingReservationDecorator < ReservationDecorator

  def formatted_start
    start_time.strftime("<b>%m/%d</b> %l:%M %p")
  end

end
