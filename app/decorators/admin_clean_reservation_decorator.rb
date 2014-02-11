class AdminCleanReservationDecorator < AdminReservationDecorator
  def status_string
    if end_time.future? && truncated_at.blank? && !deleted?
      return h.content_tag(:span, :class => "label label-success") do
        "Active"
      end
    end
    super
  end
end