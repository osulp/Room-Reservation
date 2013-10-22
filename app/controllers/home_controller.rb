class HomeController < ApplicationController
  before_filter RubyCAS::GatewayFilter, :only => :index
  def index
    calendar = get_calendar(cookies['date'])
    @presenter = CalendarPresenter.cached(calendar.day.midnight, calendar.day.tomorrow.midnight)
    @reservation = Reservation.new(:user_onid => current_user.onid, :reserver_onid => current_user.onid)
  end

  def day
    date = params[:date].to_date
    calendar = get_calendar(params[:date])
    @presenter = CalendarPresenter.cached(calendar.day.midnight, calendar.day.tomorrow.midnight)
    render :partial => 'room_list', :locals => {:floors => @floors}
  end

  private

  def get_calendar(date)
    date ||= Time.current.to_date
    date = date.to_date
    current_day = Time.current.midnight.to_date
    if date < current_day.to_date && !current_user.admin?
      date = current_day
    end
    return CalendarManager.new(date)
  end
end
