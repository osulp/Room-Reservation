class HomeController < ApplicationController
  layout Proc.new { |controller| controller.request.xhr? ? nil : "application" }
  def index
    calendar = CalendarManager.new(cookies)
    @rooms = RoomDecorator.decorate_collection(Room.all)
    @rooms.each do |room|
      room.presenter = CalendarPresenter.new(calendar.day.midnight, calendar.day.tomorrow.midnight, *managers(room))
    end
    @floors = @rooms.map(&:floor).uniq
    @filters = Filter.all
    if request.xhr?
      render :partial => 'room-list', :locals => {:floors => @floors}
    end
  end

  private

  def managers(object)
    [
        EventManager::ReservationManager.new(object)
    ]
  end
end
