class HomeController < ApplicationController
  before_filter RubyCAS::GatewayFilter, :only => :index
  def index
    calendar = get_calendar(cookies)
    @presenter = CalendarPresenter.cached(calendar.day.midnight, calendar.day.tomorrow.midnight)
    @reservation = Reservation.new(:user_onid => current_user.onid, :reserver_onid => current_user.onid)
  end

  def day
    date = params[:date].to_date
    calendar = get_calendar({:day => date.day, :month => date.month, :year => date.year})
    @presenter = CalendarPresenter.cached(calendar.day.midnight, calendar.day.tomorrow.midnight)
    render :partial => 'room_list', :locals => {:floors => @floors}
  end

  private

  def get_calendar(date)
    calendar = CalendarManager.new(date)
    current_day = Time.current.midnight
    if calendar.day < current_day.to_date && !current_user.admin?
      calendar = CalendarManager.new({:day => current_day.day, :month => current_day.month, :year => current_day.year})
    end
    return calendar
  end
end
