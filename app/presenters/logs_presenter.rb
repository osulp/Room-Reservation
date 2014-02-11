class LogsPresenter
  attr_accessor :params
  attr_reader :parent

  def initialize(parent,params={})
    @parent = parent
    self.params = params || {}
  end

  def facets
    @facets ||= Hash[(params[:facets] || {}).map{|facet, value|
      [field_map[facet.downcase.to_sym] || facet.downcase.to_sym, transform_value(facet, value)]
    }.select{|x| safe_filter_fields.include?(x[0])}]
  end

  def sort_field
    @sort_field ||= begin
      sort_field = params[:sort_field] || default_sort_field
      sort_field = field_map[sort_field] || sort_field
      params[:sort_field] = sort_field
    end
  end

  def sort_order
    return params[:sort_order] || default_sort_order
  end

  def reservations
    AdminReservationsDecorator.new(filtered_reservations.page(params[:page]).per(per_page))
  end

  def sort_params
    {
      :sort_field => sort_field,
      :sort_order => sort_order,
      :facets => facets
    }
  end

  def field(field_name)
    Logs::Field.new(field_name,self)
  end

  protected

  def transform_value(field, value)
    if field.downcase.to_sym == :user_onid
      b = BannerRecord.soft_find_by_osu_id(value.gsub(/^11(?<id>[0-9]{9})/, '\k<id>'))
      return (b.try(:onid) || value)
    end
    return value
  end

  def ordered_reservations
    Reservation.all.with_deleted.joins(:room).order("#{sort_field} #{sort_order}")
  end

  def filtered_reservations
    reservations = self.ordered_reservations
    facets.each do |facet, value|
      if facet == :start_time
        reservations = reservations.where("start_time >= ?", value)
      elsif facet == :end_time
        reservations = reservations.where("end_time <= ?", value)
      else
        reservations = reservations.where(facet => value)
      end
    end
    reservations
  end

  def default_sort_field
    :start_time
  end

  def per_page
    20
  end

  def default_sort_order
    "DESC"
  end

  def safe_filter_fields
    [:user_onid, :"rooms.name", :reserver_onid, :start_time, :end_time]
  end

  def field_map
    {:room => :"rooms.name"}.with_indifferent_access
  end
end