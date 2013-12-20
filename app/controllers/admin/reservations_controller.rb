class Admin::ReservationsController < AdminController
  respond_to :html, :json
  skip_before_filter :require_admin, :only => [:index]
  before_filter :require_staff, :only => [:index]
  layout :false

  def index
    banner_record = BannerRecord.soft_find_by_osu_id(params[:user_id])
    if banner_record
      @user = User.new(banner_record.onid)
    else
      @user = User.new(params[:user_id])
    end
    @reservations = ReservationFacade.new(@user).reservations
    respond_with(@reservations)
  end
end
