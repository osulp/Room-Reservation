module Admin::LogsHelper
  def sort_field(field, display)
    if params[:sort_field].to_s == field.to_s
      "#{display} " + link_to(raw(sort_arrow(field)), admin_logs_path(sort_params.merge(:sort_field => field.to_s, :sort_order => sort_order(field))), :data => {:sort => field})
    else
      link_to display,admin_logs_path(sort_params.merge(:sort_field => field.to_s, :sort_order => sort_order(field))), :data => {:sort => field}
    end
  end

  def sort_arrow(field)
    dir = sort_order(field) == "desc" ? "up" : "down"
    raw("<i class='fa fa-arrow-#{dir}'>&nbsp;</i>")
  end

  def sort_order(field)
    sort_order = "desc"
    if params[:sort_field].to_s == field.to_s
      sort_order = params[:sort_order] || "desc"
      sort_order.downcase!
      sort_order == "desc" ? "asc" : "desc"
    end
  end

  def sort_params
    {
        :sort_field => params[:sort_field],
        :sort_order => params[:sort_order],
        :page => params[:page],
        :filter_field => params[:filter_field],
        :filter_value => params[:filter_value]
    }
  end

  def filter_field(field, value)
    link_to value, admin_logs_path(sort_params.merge(:filter_field => field, :filter_value => value))
  end
end