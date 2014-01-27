class AdminReservationDecorator < ReservationDecorator

  def formatted_start
    start_time.strftime("%m/%d %H:%M")
  end

  def formatted_end
    "<b>#{end_time.strftime("%H:%M")}</b>"
  end

  def status_string
    if end_time.future? && truncated_at.blank? && !deleted?
      return cancel_string+" "+edit_string
    end
    super
  end
end