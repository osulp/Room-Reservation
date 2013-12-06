class MyController < ApplicationController
  before_filter RubyCAS::Filter
  respond_to :html
  def index
    # Split all reservations into coming ones and invalid ones
    @reservations = Reservation.with_deleted.where(:user_onid => current_user.onid).order(:start_time).partition do |r|
      r.end_time.future? && !r.deleted?
    end
    # TODO: Cache this if necessary; Slice this if it's too long
    @reservations[1].reverse!
    respond_with @reservations
  end
end
