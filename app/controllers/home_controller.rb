class HomeController < ApplicationController
  before_filter RubyCAS::GatewayFilter, :only => :index
  def index
    calendar = CalendarManager.new(cookies)
    @presenter = CalendarPresenter.cached(calendar.day.midnight, calendar.day.tomorrow.midnight)
    @reservation = Reservation.new(:user_onid => current_user.onid, :reserver_onid => current_user.onid)
  end

  def day
    calendar = CalendarManager.from_string(params[:date])
    @presenter = CalendarPresenter.cached(calendar.day.midnight, calendar.day.tomorrow.midnight)
    render :partial => 'room_list', :locals => {:floors => @floors}
  end
end