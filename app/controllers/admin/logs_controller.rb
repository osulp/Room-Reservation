class Admin::LogsController < AdminController
  def index
    @reservations = AdminReservationsDecorator.new(Reservation.all.with_deleted.joins(:room).order("#{sort_field} #{sort_order}").page(params[:page]).per(per_page))
  end

  private

  def per_page
    20
  end

  def sort_field
    @sort_field ||= begin
      params[:sort_field] ||= :start_time
      sort_field = params[:sort_field] || :start_time
      sort_field = "rooms.name" if sort_field == "room"
      sort_field
    end
  end

  def sort_order
    return params[:sort_order] || "DESC"
  end
end
