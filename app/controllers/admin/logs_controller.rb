class Admin::LogsController < AdminController
  def index
    @reservations = AdminReservationsDecorator.new(filtered_reservations.page(params[:page]).per(per_page))
  end

  private

  def reservations
    Reservation.all.with_deleted.joins(:room).order("#{sort_field} #{sort_order}")
  end

  def filtered_reservations
    if filter_field && filter_value && safe_filter_fields.include?(filter_field.to_sym)
      reservations.where(filter_field => filter_value)
    else
      reservations
    end
  end

  def filter_field
    f = params[:filter_field]
    if f.to_s.downcase == "room"
      f = "rooms.name"
    end
    return f
  end

  def filter_value
    params[:filter_value]
  end

  def safe_filter_fields
    [:user_onid, :"rooms.name", :reserver_onid]
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
