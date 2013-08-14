class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter RubyCAS::GatewayFilter


  protected

  def current_user
    return @current_user if @current_user
    unless current_user_username.blank?
      @current_user = User.new(current_user_username, current_user_extra_attributes)
    end
    @current_user
  end
  helper_method :current_user

  private

  def current_user_username
    session[RubyCAS::Filter.client.username_session_key]
  end

  def current_user_extra_attributes
    session[RubyCAS::Filter.client.extra_attributes_session_key]
  end
end
