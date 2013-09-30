class UserDecorator < Draper::Decorator
  delegate_all

  def tag
    h.content_tag(:span,'',:id => "user-info", :data => data_hash)
  end

  def nil?
    object.nil?
  end

  private

  def data_hash
    {:onid => onid,
     :max_reservation => self.max_reservation_time
    }
  end

end
