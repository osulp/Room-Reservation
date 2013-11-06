class HomeController < ApplicationController
  before_filter :ip_login
  before_filter RubyCAS::GatewayFilter, :only => :index
  before_filter :convert_cookie_to_param
  before_filter :admin_date_restriction
  def index
    calendar = CalendarManager.new(date)
    @presenter = CalendarPresenter.cached(calendar.day.midnight, calendar.day.tomorrow.midnight)
    @reservation = Reserver.new(:user_onid => current_user.onid, :reserver_onid => current_user.onid)
  end

  def day
    calendar = CalendarManager.new(date)
    @presenter = CalendarPresenter.cached(calendar.day.midnight, calendar.day.tomorrow.midnight)
    render :partial => 'room_list', :locals => {:floors => @floors}
  end

  private

  def date
    current_date = Time.current.to_date
    params[:date].try(:to_date) || cookies['date'].try(:to_date) || current_date
  end

  # Redirect to transform the date cookie into a date parameter - this way when they access the root
  # it has a param they can give out in the URL.
  def convert_cookie_to_param
    unless params[:date]
      params[:date] = date.strftime("%Y-%m-%-d")
      redirect_to params
    end
  end

  # Only allow admins to access past dates.
  def admin_date_restriction
    current_date = Time.current.to_date
    if date < current_date && !current_user.admin?
      params[:date] = current_date.strftime("%Y-%m-%-d")
      redirect_to params
    end
  end
end
