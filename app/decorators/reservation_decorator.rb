class ReservationDecorator < EventDecorator
  decorates_association :user
  decorates_association :reserver

  def self.collection_decorator_class
    Draper::CollectionDecorator
  end

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

  def formatted_updated_at
    updated_at.strftime("%m/%d %l:%M %p")
  end

  def formatted_truncated_at
    truncated_at.strftime("%m/%d %l:%M %p")
  end

  def status_string
    if end_time.future? && truncated_at.blank? && !deleted?
      return cancel_string
    end
    return deleted_string if deleted?
    return truncated_string unless truncated_at.blank?
    return overdue_string if key_card
    h.content_tag(:span, :class => "label") {"Expired"}
  end

  def overdue_string
    h.content_tag(:span, :class => 'label label-important') {"Key Card Overdue"}
  end

  def deleted_string
    h.content_tag(:span, :class => "label label-important") {"Cancelled #{formatted_deleted_at}"}
  end

  def keycard_checkout
    return if start_time > Time.current+12.hours # TODO: Make this configurable.
    return "Checked Out" if key_card
    h.text_field_tag "keycard-checkout-#{self.id}", '', :class => 'keycard-checkout', :placeholder => "Scan Keycard to Check Out", :data => {:id => id}
  end

  def cancel_string
    h.content_tag(:span, :data => {"room-id" => self.room.id, "room-name" => self.room.name}) do
      h.content_tag(:span) do
        h.link_to "Cancel", '#', :class => "btn btn-danger bar-info", :data => data_hash.merge(:action => "cancel")
      end
    end
  end

  def edit_string
    h.content_tag(:span, :data => {"room-id" => self.room.id, "room-name" => self.room.name}) do
      h.content_tag(:span) do
        h.content_tag(:span, "", :data => {:start => available_times[:start_time]}, :class => "hidden bar-success") +
        h.link_to("Edit", '#', :class => "btn btn-primary bar-info", :data => data_hash.merge(:action => "update"))
      end
    end
  end


  def truncated_string
    return checked_in_string unless current_originator == "Truncator"
    truncator_string
  end

  def checked_in_string
    h.content_tag(:span, :class => "label label-info") do
      "Checked In #{formatted_truncated_at}"
    end
  end

  def truncator_string
    checked_in_string
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
        end: (payload.end_time).iso8601.to_s,
        user_onid: user_onid
    }
  end

  def available_times
    {:start_time => available_slot.start_time.iso8601.to_s, :end_time => available_slot.end_time.iso8601.to_s}
  end

  def available_slot
    @available_slot ||= availability_events.select{|event| event.start_time <= start_time && event.end_time >= end_time && event.kind_of?(AvailableDecorator)}.first || payload
  end

  def availability_events
    return @availability_events if @availability_events
    events = availability_checker.decorated_events(start_time.midnight)
    current_time = Time.current
    availability_checker.decorated_events(start_time.midnight).each_with_index do |event, i|
      if events[i].payload == payload
        # This effectively deletes the current event from the cached item.
        events[i+1].start_time = events[i].start_time if events[i+1] && !events[i-1]
        events[i-1].end_time = events[i].end_time if events[i-1]
        events[i].start_time = events[i].end_time
        # Merge Available Decorators
        if events[i+1].kind_of?(AvailableDecorator) && events[i-1].kind_of?(AvailableDecorator)
          events[i-1].end_time = events[i+1].end_time
          events[i+1].start_time = events[i+1].end_time
        end
      else
        # Restrict to current day
        if events[i].start_time != events[i].end_time && events[i].start_time >= current_time.midnight && events[i].start_time <= current_time.tomorrow.midnight
          events[i].start_time = current_time
          events[i].end_time = current_time if events[i].end_time < events[i].start_time
        end
      end
    end
    @availability_events = events.select{|x| x.start_time != x.end_time && x.payload != "delete"}
    return @availability_events
  end

  def availability_checker
    @availability_checker ||= CalendarPresenter.cached(start_time.midnight, end_time.tomorrow.midnight).rooms.find{|r| r.id == payload.room_id}
  end

end
