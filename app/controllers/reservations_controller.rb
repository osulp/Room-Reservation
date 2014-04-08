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
    result = ReservationDecorator.decorate_collection(result.includes(:key_card, :room))
    respond_with(result)
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
    reserver_params = self.reserver_params
    if reserver_params[:errors]
      respond_with(reserver_params, :location => root_path, :responder => JsonResponder, :status => :not_found)
    else
      reserver = Reserver.new(reserver_params)
      reserver.reserver = current_user unless params[:reserver][:user_onid_id] && current_user.staff?
      reserver.user = current_user if params[:reserver][:user_onid] == current_user.onid
      reserver.save
      respond_with(reserver, :location => root_path, :responder => JsonResponder, :serializer => ReservationSerializer)
    end
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
    params[:reserver] ||= {}
    params[:reserver] = params[:reserver].merge(:reserver_onid => current_user.onid)
    return flex_params if flex_params
    params.require(:reserver).permit(:reserver_onid, :user_onid, :start_time, :room_id, :end_time, :description, :key_card_key)
  end

  def flex_params
    if params[:reserver][:room_name] && !params[:reserver][:room_id]
      room = Room.where(:name => params[:reserver][:room_name]).first
      if !room
        return {:errors => "Invalid room requested."}
      end
      params[:reserver][:room_id] = room.id
    end
    if params[:reserver][:user_onid_id] && !params[:reserver][:user_onid]
      b = BannerRecord.soft_find_by_osu_id(params[:reserver][:user_onid_id])
      if !b
        return {:errors => "No user found for that ID card."}
      end
      params[:reserver][:user_onid] = b.onid
      if current_user.staff?
        # Impersonate user for reservation - this is for kiosk.
        params[:reserver][:reserver_onid] = b.onid
      else
        return {:errors => "Invalid permissions."}
      end
    end
    if params[:reserver][:startTime] && params[:reserver][:endTime] && params[:reserver][:date] && !params[:reserver][:start_time] && !params[:reserver][:end_time]
      params[:reserver][:start_time] = Time.zone.parse("#{params[:reserver][:date]} #{params[:reserver][:startTime]}").iso8601
      params[:reserver][:end_time] = Time.zone.parse("#{params[:reserver][:date]} #{params[:reserver][:endTime]}").iso8601
    end
    return
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
