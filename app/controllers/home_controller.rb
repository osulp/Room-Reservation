class HomeController < ApplicationController
  before_filter RubyCAS::GatewayFilter, :only => :index
  layout Proc.new { |controller| controller.request.xhr? ? nil : "application" }
  def index
    calendar = CalendarManager.new(cookies)
    load_rooms(calendar)
    @filters = Filter.all
  end

  def day
    date = params[:date].split("-")
    raise "Invalid date given" if date.length != 3
    calendar_hash = {:year => date[0], :month => date[1], :day => date[2]}
    calendar = CalendarManager.new(calendar_hash)
    load_rooms(calendar)
    etag = Digest::MD5.hexdigest(@rooms.map{|x| x.presenter.cache_key}.join("/"))
    if stale?(etag: etag)
      render :partial => 'room_list', :locals => {:floors => @floors}
    end
  end

  private

  def load_rooms(calendar)
    @rooms = RoomDecorator.decorate_collection(Room.includes(:filters).all)
    @rooms.each do |room|
      room.presenter = CalendarPresenter.new(calendar.day.midnight, calendar.day.tomorrow.midnight, *managers(room))
    end
    @floors = @rooms.map(&:floor).uniq
  end


  def hours_manager
    @hours_manager ||= EventManager::HoursManager.new
  end
  def managers(object)
    [
        EventManager::ReservationManager.new(object),
        hours_manager,
        EventManager::CleaningRecordsManager.new(object)
    ]
  end
end
