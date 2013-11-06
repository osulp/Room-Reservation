require 'ipaddr'
class ApplicationController < ActionController::Base
  protect_from_forgery


  protected

  def current_user
    @current_user ||= UserDecorator.new(User.new(current_user_username, current_user_extra_attributes))
  end
  helper_method :current_user

  def require_login
    ip_login
    redirect_to login_path(:source => request.original_fullpath) if current_user.nil?
  end

  def ip_login
    return unless current_user_username.blank?
    ip = IPAddr.new(request.remote_ip).to_i
    auto_login = AutoLogin.joins(:ip_addresses).where(:"ip_addresses.ip_address_i" => ip).first
    RubyCAS::Filter.fake(auto_login.username) if auto_login
  end

  private

  def current_user_username
    session[RubyCAS::Filter.client.username_session_key]
  end

  def current_user_extra_attributes
    session[RubyCAS::Filter.client.extra_attributes_session_key]
  end
end
