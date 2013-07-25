class HomeController < ApplicationController
  def index
    @floors = [1, 2, 5, 6]
    @rooms = Room.all
    @rooms.each { |room| room.load_reservations_today Time.current }
  end
end
