module Admin::LogsHelper
  def sort_field(field, display)
    if params[:sort_field].to_s == field.to_s
      "#{display} " + link_to(raw(sort_arrow(field)), admin_logs_path(:sort_field => field.to_s, :page => params[:page], :sort_order => sort_order(field)))
    else
      link_to raw("#{display} #{sort_arrow(field)}"),admin_logs_path(:sort_field => field.to_s, :page => params[:page], :sort_order => sort_order(field))
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
end