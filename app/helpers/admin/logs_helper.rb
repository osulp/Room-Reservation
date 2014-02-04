# NOTE: A lot of this needs to be refactored into objects.

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

  def facet_to_label(facet)
    facet_label_hash[facet] || facet
  end

  def link_to_delete_label(facet)
    s = sort_params
    facets = s[:facets]
    facets = facets.except(facet)
    s[:facets] = facets
    link_to raw("&times;"), admin_logs_path(s), :class => "close"
  end

  # TODO: Move to i18n.
  def facet_label_hash
    {
      "rooms.name" => "Room",
      "user_onid" => "User",
      "reserver_onid" => "Reserver",
      "end_time" => "Ends Before",
      "start_time" => "Starts After"
    }.with_indifferent_access
  end

  def sort_params
    {
        :sort_field => params[:sort_field],
        :sort_order => params[:sort_order],
        :page => params[:page],
        :facets => facets
    }
  end

  def facets
    @facets ||= params[:facets] || {}
  end

  def filter_field(field, value)
    link_to value, filter_field_link(field, value)
  end

  def filter_field_link(field, value)
    facets = sort_params[:facets]
    facets = facets.merge(field => value)
    admin_logs_path(sort_params.merge(:facets => facets))
  end
end