class UserDecorator < Draper::Decorator
  delegate_all

  def tag
    h.content_tag(:span,'',:id => "user-info", :data => data_hash)
  end

  # TODO: Change this.
  def max_reservation_time
    return @max_reservation_time if @max_reservation_time
    @max_reservation_time = default_reservation_time
    if banner_record && banner_record.status
      @max_reservation_time = reservation_times[banner_record.status.downcase] if reservation_times.has_key?(banner_record.status.downcase)
    end
    @max_reservation_time = @max_reservation_time.to_i*60
    return @max_reservation_time
  end

  def nil?
    object.onid.nil?
  end

  private

  def default_reservation_time
    APP_CONFIG["users"]["reservation_times"]["default"]
  end

  def reservation_times
    APP_CONFIG["users"]["reservation_times"]
  end

  def data_hash
    {:onid => onid,
     :max_reservation => self.max_reservation_time
    }
  end

end
