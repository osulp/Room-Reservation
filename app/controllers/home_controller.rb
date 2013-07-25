class HomeController < ApplicationController
  def index
    @floors = [1, 2, 5, 6]
    @rooms = Room.all

  end
end
