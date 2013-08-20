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
    render :partial => 'room_list', :locals => {:floors => @floors}
  end

  private

  def load_rooms(calendar)
    @rooms = RoomDecorator.decorate_collection(Room.includes(:filters).all)
    @rooms.each do |room|
      room.presenter = CalendarPresenter.new(calendar.day.midnight, calendar.day.tomorrow.midnight, *managers(room,calendar))
    end
    @floors = @rooms.map(&:floor).uniq
  end


  def hours_manager
    @hours_manager ||= EventManager::HoursManager.new
  end
  def reservations(calendar=nil)
    return nil unless calendar
    @reservations ||= {}
    return @reservations[calendar.day] if @reservations.has_key?(calendar.day)
    @reservations[calendar.day] = Reservation.where("start_time <= ? AND end_time >= ?", calendar.day.tomorrow.midnight, calendar.day.midnight).group_by(&:room_id)
    return @reservations[calendar.day]
  end
  def managers(object,calendar=nil)
    [
        EventManager::ReservationManager.new(object,reservations(calendar)),
        hours_manager
    ]
  end
end
