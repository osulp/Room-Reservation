class ReservationsController < ApplicationController
  respond_to :json, :html
  include_root_in_json = false
  before_filter :require_login, :only => [:create, :destroy, :show, :update]
  before_filter RubyCAS::Filter, :only => :index
  layout false, :only => :upcoming

  def index
    @reservations = ReservationFacade.new(current_user).reservations
    @reservation = Reserver.new # Just for the update popup. Should refactor this eventually.
    respond_with @reservations
  end

  def upcoming
    @upcoming_reservations = Reservation.where("end_time >= ? AND end_time <= ? AND reservations.description IS NOT NULL AND reservations.description != ''", Time.current, Time.current+30.days).joins(:room).order("start_time ASC")
    @upcoming_reservations = UpcomingReservationDecorator.decorate_collection(@upcoming_reservations)
  end

  def current_user_reservations
    result = current_user.reservations
    result = Reservation.all if can?(:destroy, Reservation.new)
    if params[:date]
      date = Time.zone.parse(params[:date])
      result = result.where("start_time <= ? AND end_time >= ?", date.tomorrow.midnight, date.midnight)
    end
    result.includes(:key_card)
    respond_with(Array.wrap(result))
  end

  def show
    @reservation = Reservation.find(params[:id])
    authorize! :read, @reservation
    respond_with(@reservation)
  end

  # Returns availability in seconds given a time
  def availability
    available_time = max_availability
    start_time = Time.zone.parse(params[:start])
    room = Room.find(params[:room_id])
    blacklist = Reservation.where(:id => (params['blacklist']||'').split(","))
    blacklist = blacklist.first unless blacklist.empty?
    availability_checker = AvailabilityChecker.new(room, start_time, start_time+max_availability,blacklist)
    unless availability_checker.available?
      available_time = availability_checker.events.first.start_time - start_time
      available_time = 0 if available_time < 0
    end
    respond_with({:availability => available_time.to_i})
  end

  def all_availability
    start_time = Time.zone.parse(params[:start])
    result = {}
    availability_checker = AvailabilityChecker.new(Room.all, start_time, start_time+24.hours)
    availability_checker.events.each do |room, events|
      available_time = 24.hours
      unless events.empty?
        available_time = events.first.start_time - start_time
        available_time = 0 if available_time < 0
      end
      result[room] = {:availability => available_time.to_i}
    end
    respond_with(result)
  end

  def create
    reserver = Reserver.new(reserver_params)
    reserver.reserver = current_user
    reserver.user = current_user if params[:reserver][:user_onid] == current_user.onid
    reserver.save
    respond_with(reserver, :location => root_path, :responder => JsonResponder, :serializer => ReservationSerializer)
  end

  def update
    reservation = Reservation.find(params[:id])
    authorize! :update, reservation
    reserver_params = self.reserver_params
    key = reserver_params.delete(:key_card_key)
    reservation.attributes = reserver_params
    reserver = Reserver.new(reservation)
    reserver.key_card_key = key
    reserver.reserver = current_user
    reserver.user = current_user if params[:reserver][:user_onid] == current_user.onid
    reserver.save
    respond_with(reserver, :location => root_path, :responder => JsonResponder, :serializer => ReservationSerializer)
  end

  def destroy
    reservation = Reservation.find(params[:id])
    canceller = Canceller.new(reservation, current_user)
    canceller.save
    respond_with(canceller, :location => root_path, :responder => JsonResponder)
  end


  protected

  def reserver_params
    params[:reserver] = params[:reserver].merge(:reserver_onid => current_user.onid)
    params.require(:reserver).permit(:reserver_onid, :user_onid, :start_time, :room_id, :end_time, :description, :key_card_key)
  end

  # @TODO: Make this configurable
  def max_availability
    current_user.max_reservation_time
  end

  def default_serializer_options
    {
        :root => false
    }
  end
end
