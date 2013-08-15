class HomeController < ApplicationController
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
    render :partial => 'room-list', :locals => {:floors => @floors}
  end

  private

  def load_rooms(calendar)
    @rooms = RoomDecorator.decorate_collection(Room.all)
    @rooms.each do |room|
      room.presenter = CalendarPresenter.new(calendar.day.midnight, calendar.day.tomorrow.midnight, *managers(room))
    end
    @floors = @rooms.map(&:floor).uniq
  end

  def managers(object)
    [
        EventManager::ReservationManager.new(object)
    ]
  end
end
