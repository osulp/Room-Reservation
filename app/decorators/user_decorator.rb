class UserDecorator < Draper::Decorator
  delegate_all

  def tag
    h.content_tag(:span,'',:id => "user-info", :data => data_hash)
  end
  private

  def data_hash
    {:onid => onid}
  end

end
