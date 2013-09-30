class HomeController < ApplicationController
  before_filter RubyCAS::GatewayFilter, :only => :index
  def index
    calendar = CalendarManager.new(cookies)
    @time_range = (calendar.day.midnight..calendar.day.tomorrow.midnight)
    @presenter = CalendarPresenter.cached(calendar.day.midnight, calendar.day.tomorrow.midnight)
    @reservation = Reservation.new(:user_onid => current_user.onid, :reserver_onid => current_user.onid)
  end

  def day
    date = params[:date].split("-")
    raise "Invalid date given" if date.length != 3
    calendar_hash = {:year => date[0], :month => date[1], :day => date[2]}
    calendar = CalendarManager.new(calendar_hash)
    @presenter = CalendarPresenter.cached(calendar.day.midnight, calendar.day.tomorrow.midnight)
    render :partial => 'room_list', :locals => {:floors => @floors}
  end
end