class ReservationController < ApplicationController
  respond_to :json
  include_root_in_json = false
  def current_user_reservations
    if params.has_key?(:date)
      date = Time.zone.parse(params[:date])
      result = current_user.reservations.where("start_time <= ? AND end_time >= ?", date.tomorrow.midnight, date.midnight)
    else
      result = current_user.reservations
    end
    respond_with(Array.wrap(result))
  end


  protected

  def default_serializer_options
    {
        root: false
    }
  end
end
