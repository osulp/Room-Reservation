class HomeController < ApplicationController
  before_filter RubyCAS::GatewayFilter, :only => :index
  layout Proc.new { |controller| controller.request.xhr? ? nil : "application" }
  def index
    calendar = CalendarManager.new(cookies)
    @time_range = (calendar.day.midnight..calendar.day.tomorrow.midnight)
    @presenter = CalendarPresenter.cached(calendar.day.midnight, calendar.day.tomorrow.midnight)
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