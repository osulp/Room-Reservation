class Admin::ReservationsController < AdminController
  respond_to :html, :json
  skip_before_filter :require_admin, :only => [:index, :checkout]
  before_filter :require_staff, :only => [:index, :checkout]
  layout :false, :except => :history

  def index
    banner_record = BannerRecord.soft_find_by_osu_id(params[:user_id])
    if banner_record
      @user = User.new(banner_record.onid)
    else
      @user = User.new(params[:user_id])
    end
    @reservations = ReservationFacade.new(@user, current_user).reservations
    respond_with(@reservations)
  end

  # Show past versions of a given reservation
  def history
    @reservation = Reservation.find(params[:id])
    respond_with(@reservation)
  end

  def checkout
    keycard = KeyCard.where(:key => params[:key]).first!
    reservation = Reservation.find(params[:id])
    @checkout_service = Keycards::CheckoutService.new(keycard, reservation, current_user)
    @checkout_service.save
    respond_with(@checkout_service, :location => root_path,:responder => JsonResponder)
  end

end
