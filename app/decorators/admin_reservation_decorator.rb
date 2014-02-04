class AdminReservationDecorator < ReservationDecorator

  delegate :current_page, :total_pages, :limit_value

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

  def truncator_string
    h.content_tag(:span, :class => "label label-info") do
      "Truncated #{formatted_truncated_at}"
    end
  end

  def checked_in_string
    h.content_tag(:span, :class => "label label-info") do
      "Checked In #{formatted_truncated_at}"
    end
  end
end