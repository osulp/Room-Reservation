class HomeController < ApplicationController
  layout Proc.new { |controller| controller.request.xhr? ? nil : "application" }
  def index
    calendar = CalendarManager.new(cookies)

    @floors = [1, 2, 5, 6]
    @rooms = Room.all
    @rooms.each { |room| room.load_reservations_today calendar.day }

    if request.xhr?
      render :partial => 'room-list'
    end
  end
end
