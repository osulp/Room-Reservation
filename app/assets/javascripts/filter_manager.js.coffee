jQuery ->
  window.FilterManager = new FilterManager
class FilterManager
  constructor: ->
    @filters = []
    return if $("#room-filters").length == 0
    $("#room-filters input").each (key, element) =>
      @filters.push new Filter($(element), this)
  clear_all_filters: ->
    for filter in @filters
      filter.element.prop('checked',false) unless filter.all_filter?
  apply_filters: ->
    @all_filter().element.prop('checked', false) if this.applied_filter_count() > 0
    @all_filter().element.prop('checked', true) if this.applied_filter_count() <= 0
    $(".room-data").attr("style", null)
    $("a[href^='#floor']").parent().show()
    $("*[id^=floor-]").attr("style",null)
    unless @all_filter().is_checked()
      for filter in @filters
        if filter.is_checked()
          $(".room-data:not(.filter-#{filter.id})").hide()
    $("*[id^=floor-]").each ->
      element = $(this)
      # Hide any floors that have all room data elements filtered out.
      displays = jQuery.unique(element.find(".room-data").map(-> $(this).css("display")))
      if displays.length == 1 && displays[0] == "none"
        console.log("Hiding #{element.attr('id')}")
        element.hide()
        $("a[href^='##{element.attr('id')}']").parent().hide()
      else
        console.log("Not hiding #{element.attr('id')}")
  all_filter: ->
    return @all_filter_element if @all_filter_element?
    for filter in @filters
      @all_filter_element = filter if filter.all_filter?
    return @all_filter_element
  applied_filter_count: ->
    filter_count = 0
    for filter in @filters
      filter_count++ if filter.is_checked() && !filter.all_filter?
    return filter_count
class Filter
  constructor: (element, manager) ->
    @manager = manager
    @element = element
    @element.click(this.clicked)
    @id = @element.val()
    if @element.attr('id') == "filter_all"
      @all_filter = true
    return
  clicked: =>
    # Don't let the all_filter get disabled by the user.
    if @all_filter?
      if !this.is_checked()
        return false
      else
        @manager.clear_all_filters()
    @manager.apply_filters()
    return
  is_checked: ->
    @element.prop('checked')
