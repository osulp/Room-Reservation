class ApplicationController < ActionController::Base
  protect_from_forgery


  protected

  def current_user
    return @current_user if @current_user
    unless current_user_username.blank?
      @current_user = UserDecorator.new(User.new(current_user_username, current_user_extra_attributes))
    else
      @current_user = NullObject.new
    end
    @current_user
  end
  helper_method :current_user

  def require_login
    redirect_to login_path if current_user.nil?
  end

  private

  def current_user_username
    session[RubyCAS::Filter.client.username_session_key]
  end

  def current_user_extra_attributes
    session[RubyCAS::Filter.client.extra_attributes_session_key]
  end
end