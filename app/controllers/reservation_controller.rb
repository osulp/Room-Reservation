class ReservationController < ApplicationController
  respond_to :json
  include_root_in_json = false
  def current_user_reservations
    respond_with(Array.wrap(current_user.reservations.where("end_time > ?", Time.current.midnight)))
  end


  protected

  def default_serializer_options
    {
        root: false
    }
  end
end
