class HomeController < ApplicationController
  before_filter RubyCAS::GatewayFilter, :only => :index
  layout Proc.new { |controller| controller.request.xhr? ? nil : "application" }
  def index
    calendar = CalendarManager.new(cookies)
    @presenter = CalendarPresenter.new(calendar.day.midnight, calendar.day.tomorrow.midnight, *managers)
  end

  def day
    date = params[:date].split("-")
    raise "Invalid date given" if date.length != 3
    calendar_hash = {:year => date[0], :month => date[1], :day => date[2]}
    calendar = CalendarManager.new(calendar_hash)
    @presenter = CalendarPresenter.new(calendar.day.midnight, calendar.day.tomorrow.midnight, *managers)
    render :partial => 'room_list', :locals => {:floors => @floors}
  end

  private

  def managers
    [
        EventManager::ReservationManager.new,
        EventManager::HoursManager.new,
        EventManager::CleaningRecordsManager.new
    ]
  end
end
