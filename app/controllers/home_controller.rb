class HomeController < ApplicationController
  layout Proc.new { |controller| controller.request.xhr? ? nil : "application" }
  def index
    year = cookies[:year]
    month = cookies[:month]
    day = cookies[:day]
    if year.blank? || month.blank? || day.blank?
      the_day = Time.current
    else
      the_day = Time.new year.to_i, month.to_i, day.to_i
    end

    @floors = [1, 2, 5, 6]
    @rooms = Room.all
    @rooms.each { |room| room.load_reservations_today the_day }

    if request.xhr?
      render :partial => 'room-list'
    end
  end
end
