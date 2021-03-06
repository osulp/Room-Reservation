class HomeController < ApplicationController
  before_filter RubyCAS::GatewayFilter, :only => :index, :if => -> {current_user.nil?}
  before_filter :convert_cookie_to_param
  before_filter :admin_date_restriction

  def index
    @presenter = presenter
    @reservation = Reserver.new(:user_onid => current_user.onid, :reserver_onid => current_user.onid)
  end

  def day
    @presenter = presenter
    render :partial => 'room_list', :locals => {:floors => @floors}
  end

  def timebars
    start_time = date.midnight
    render :partial => "time_list", :locals => {:start_time => start_time }
  end

  def presenter
    calendar = CalendarManager.new(date)
    @presenter ||= CalendarPresenter.cached(calendar.day.midnight, calendar.day.tomorrow.midnight, false, ignore_managers)
  end
  helper_method :presenter

  private

  def ignore_managers
    return [EventManager::HoursManager, EventManager::CleaningRecordsManager] unless patron_mode?
    []
  end

  def date
    current_date = Time.current.to_date
    params[:date].try(:to_date) || cookies['date'].try(:to_date) || current_date
  end

  # Redirect to transform the date cookie into a date parameter - this way when they access the root
  # it has a param they can give out in the URL.
  def convert_cookie_to_param
    unless params[:date]
      params[:date] = date.strftime("%Y-%m-%-d")
      redirect_to day_path(params[:date])
    end
  end

  # Disable past dates.
  def admin_date_restriction
    current_date = Time.current.to_date
    # Removing view_past_dates for :calendar to prevent confusion in the home
    # for users. Not sure if there was a use case for this feature, but it's
    # allowing reservations in the past. To access/browse past reservations,
    # admin users can go to /admin/logs Disabling here for now to resolve
    # https://github.com/osulp/Room-Reservation/issues/362
    #
    # if date < current_date && !can?(:view_past_dates, :calendar)
    #
    if date < current_date
      params[:date] = current_date.strftime("%Y-%m-%-d")
      redirect_to day_path(params[:date])
    end
  end
end
