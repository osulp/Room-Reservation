class ReservationDecorator < EventDecorator
  decorates_association :user
  decorates_association :reserver

  def color
    return 'danger'
  end

  def formatted_start
    start_time.strftime("%m/%d %l:%M %p")
  end

  def formatted_end
    end_time.strftime("%l:%M %p")
  end

  def formatted_deleted_at
    deleted_at.strftime("%m/%d %l:%M %p")
  end

  def formatted_created_at
    created_at.strftime("%m/%d %l:%M %p")
  end

  def formatted_truncated_at
    truncated_at.strftime("%m/%d %l:%M %p")
  end

  def status_string
    return cancel_string if end_time.future? && truncated_at.blank?
    return deleted_string if deleted?
    return truncated_string unless truncated_at.blank?
    h.content_tag(:span, :class => "label") {"Expired"}
  end

  def deleted_string
    h.content_tag(:span, :class => "label label-important") {"Cancelled #{formatted_deleted_at}"}
  end

  def cancel_string
    h.link_to "Cancel", '#', :class => "btn btn-danger bar-info", :data => data_hash
  end

  def truncated_string
    h.content_tag(:span, :class => "label label-info") do
      "Checked In #{formatted_truncated_at}"
    end
  end

  def payload
    if object.respond_to?(:payload)
      object.payload
    else
      self
    end
  end

  def data_hash
    {
        :id => self.id,
        start: (payload.start_time).iso8601.to_s,
        end: (payload.end_time).iso8601.to_s
    }
  end

end
