class Admin::LogsController < AdminController
  def index
    @reservations = AdminReservationsDecorator.new(reservations.page(params[:page]).per(per_page))
  end

  private

  def reservations
    Reservation.all.with_deleted.joins(:room).order("#{sort_field} #{sort_order}")
  end

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
