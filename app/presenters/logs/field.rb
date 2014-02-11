class Logs::Field
  include Draper::ViewHelpers
  attr_accessor :name
  attr_reader :parent

  def initialize(name, parent)
    @parent = parent
    self.name = name
  end

  def label
    I18n.t("logs.#{name}") || name
  end

  def delete_link
    s = parent.sort_params
    facets = s[:facets]
    facets = facets.except(name)
    s[:facets] = facets
    h.link_to h.raw("&times;"), h.admin_logs_path(s), :class => "close"
  end

  def sort_link
    if sorted?
      "#{label} " + h.link_to(h.raw(sort_arrow), h.admin_logs_path(sort_params), :data => {:sort => name})
    else
      h.link_to label, h.admin_logs_path(sort_params), :data => {:sort => name}
    end
  end

  def sort_arrow
    dir = sort_order == "desc" ? "up" : "down"
    h.raw("<i class='fa fa-arrow-#{dir}'>&nbsp;</i>")
  end

  def sort_order
    sort_order = "desc"
    if sorted?
      sort_order = parent.sort_order || "desc"
      sort_order.downcase!
      sort_order == "desc" ? "asc" : "desc"
    end
  end

  def facet_link(value)
    facets = parent.sort_params[:facets]
    facets = facets.merge(name => value)
    h.admin_logs_path(parent.sort_params.merge(:facets => facets))
  end

  def full_facet_link(value)
    h.link_to value, facet_link(value)
  end

  private

  def sort_params
    parent.sort_params.merge(:sort_field => name.to_s, :sort_order => sort_order)
  end

  def sorted?
    parent.sort_field.to_s == name.to_s
  end

end