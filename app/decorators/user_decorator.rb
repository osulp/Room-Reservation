class UserDecorator < Draper::Decorator
  decorates :user
  delegate_all

  def tag
    h.content_tag(:span,'',:id => "user-info", :data => data_hash)
  end

  def name
    if banner_record && !banner_record.fullName.blank?
      return banner_record.fullName
    end
    onid
  end

  def nil?
    object.nil?
  end

  def min_date
    # Note: returning '' here for the staff role allows the calendar to enable
    # any day in the calendar, including past dates. Not sure if there was a
    # use case for this feature, but it's allowing reservations in the past.
    # Disabling for now to resolve https://github.com/osulp/Room-Reservation/issues/362
    #
    # return '' if object.staff?
    date = Time.current
    "#{date.month}/#{date.day}/#{date.year}"
  end

  def max_date
    return '' if object.staff?
    return '' if Setting.day_limit.to_i == 0
    date = Time.current+Setting.day_limit.to_i.days
    "#{date.month}/#{date.day}/#{date.year}"
  end

  def reservation_popup_partial
    return "admin_reservation_popup" if object.staff?
    "reservation_popup"
  end

  private

  def data_hash
    {:onid => onid,
     :max_reservation => self.max_reservation_time,
     :staff => object.staff?
    }
  end

end
