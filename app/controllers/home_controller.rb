class HomeController < ApplicationController
  layout Proc.new { |controller| controller.request.xhr? ? nil : "application" }
  def index
    calendar = CalendarManager.new(cookies)
    @rooms = RoomDecorator.decorate_collection(Room.all)
    @floors = @rooms.map(&:floor).uniq
    @rooms.each { |room| room.load_hours_today calendar.day }

    if request.xhr?
      render :partial => 'room-list', :locals => {:floors => @floors}
    end
  end
end
