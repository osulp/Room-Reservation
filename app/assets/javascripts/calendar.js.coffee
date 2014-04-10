jQuery ->
  window.CalendarManager = new CalendarManager
class CalendarManager
  constructor: ->
    this.initialize_calendar() if $("#datepicker").length > 0
    # When events are updated, refresh the calendar.
    $.event.trigger({type: "calendarInitialized", time: new Date(), element: this})
    $(document).on("eventsUpdated", => this.refresh_view())
  initialize_calendar: ->
    @datepicker = $("#datepicker")
    @datepicker.datepicker(onSelect: this.selected_date, showButtonPanel: true, minDate: @datepicker.data("min-date"), maxDate: @datepicker.data("max-date"))
    $(document).on("click","button[data-handler=today]",this.go_to_today)
    cached_date = this.get_date_from_cookie()
    @datepicker.datepicker("setDate","#{cached_date[1]}/#{cached_date[2]}/#{cached_date[0]}")
    date = @datepicker.datepicker("getDate")
    @date_selected = [date.getFullYear(), date.getMonth()+1, date.getDate()]
    this.truncate_to_now()
    this.color_reservations("#{@date_selected[0]}-#{@date_selected[1]}-#{@date_selected[2]}")
    this.bind_pop_state()
    this.bind_day_limit_hover()
    window.setInterval((=> this.update_truncation()),30000)
    $("body").on("click", "*[data-action=login]", => this.login())
    $("body").on("touchend", "*[data-action=login]", => this.login())
  login: ->
    window.location = "/login?source=#{window.location.pathname}"
  go_to_today: =>
    day = moment().tz("America/Los_Angeles").format("MM/DD/YYYY")
    @datepicker.datepicker("setDate", day)
    current_date = @datepicker.datepicker("getDate")
    this.selected_date(current_date,@datepicker)
    return
  get_truncation_increment: ->
    start_time = moment($(".room-data-wrap").data("start")).tz("America/Los_Angeles")
    current_time = moment().tz("America/Los_Angeles")
    difference = current_time - start_time
    return Math.ceil(difference/1000/60/10)
  truncate_to_now: =>
    start_time = moment($(".room-data-wrap").data("start")).tz("America/Los_Angeles")
    current_time = moment().tz("America/Los_Angeles")
    @current_increment = this.get_truncation_increment()
    truncation_time = start_time.clone().add('minutes',@current_increment*10)
    bar_length = @current_increment*60*10/180
    return if @current_increment < 0 || (current_time - start_time) > 24*60*60*1000
    $(".tab-pane").show()
    $(".room-data-wrap .bar").each (key, item) =>
      item = $(item)
      start_offset = item.parent().offset().top
      start_at = item.offset().top - start_offset
      end_at = item.height()+start_at
      if start_at < bar_length
        if end_at > bar_length
          if(item.data("start")? && item.hasClass("bar-success"))
            truncation_time.second(0)
            truncation_time.minute(Math.ceil(truncation_time.minute()/10)*10)
            item.data("start",truncation_time.toISOString())
            item.attr("data-start", truncation_time.toISOString())
          return true if User.current().get_value("staff") == true && !item.hasClass("bar-success")
          new_item = $("<div>")
          new_item.addClass("bar bar-warning")
          new_item.height(bar_length-start_at)
          item.before(new_item)
          item.height(end_at - bar_length)
        else
          if User.current().get_value("staff") == true
            if item.hasClass("bar-success")
              item.removeClass("bar-success")
              item.addClass("bar-warning")
          else
            item.removeClass("bar-success")
            item.removeClass("bar-info")
            item.addClass("bar-warning")
            item.attr("data-id","")
          item.attr("data-original-title","")
    $(".bar-warning").attr("data-action",null)
    $(".tab-pane").attr("style",null)
    $.event.trigger({type: "eventsTruncated", time: new Date()})
    return
  refresh_view: ->
    if @datepicker?
      current_date = @datepicker.datepicker("getDate")
      this.selected_date(current_date,@datepicker)
    else
      location.reload()
  selected_date: (dateText, inst) =>
    date = @datepicker.datepicker("getDate")
    m = moment(date).utc()
    $("#date-header").text(m.format("dddd, MMMM DD, YYYY"))
    @date_selected = [date.getFullYear(), date.getMonth()+1, date.getDate()]
    this.day_changed(date.getFullYear(), date.getMonth()+1, date.getDate())
    return
  day_changed: (year, month, day) =>
    # Set cookies
    this.update_cookie(year, month, day)
    this.load_day(year, month, day)
    window.EventsManager.dayChanged(year,month,day)
    # Highlight day on map
    $(".day").removeClass("day-selected")
    $(".day[day=#{day}]").addClass("day-selected")
  load_day: (year, month, day) ->
    $('#loading-spinner').show() unless @background_loading
    cookie_requested = this.get_date_from_cookie()
    history.pushState?({}, '', "/day/#{year}-#{month}-#{day}") unless @push == false
    @push = true
    @cached_reservations = null
    $.get("/home/day/#{encodeURIComponent("#{year}-#{month}-#{day}")}", (data) =>
      return unless @date_selected.toString() == [year, month, day].toString()
      this.populate_calendar(data)
      $.event.trigger({type: "dayLoaded", time: new Date()})
    )
    return
  populate_calendar: (data) ->
    @cached_data = data
    year = @date_selected[0]
    month = @date_selected[1]
    day = @date_selected[2]
    this.update_room_bars(data)
    $('#loading-spinner').hide()
    window.FilterManager.apply_filters()
    this.truncate_to_now()
    window.TooltipManager.set_tooltips()
    this.color_reservations("#{year}-#{month}-#{day}")
    window.ReservationPopupManager.hide_popup() unless @background_loading
    window.CancelPopupManager.hide_popup() unless @background_loading
    @background_loading = false
    window.FayeManager?.subscribe_to_date("#{year}-#{month}-#{day}")
  update_room_bars: (data) ->
    # Close all popovers on room-name
    $('.room-name').popover('hide')

    new_room_list = $(data)
    for i in [0..new_room_list.length-1]
      div = $(new_room_list[i])
      id = div.attr('id')
      html = div.html()
      $('#' + id).html(html)
  update_truncation: ->
    if this.get_truncation_increment() != @current_increment && @cached_data?
      @background_loading = true
      this.populate_calendar(@cached_data)
  color_reservations: (date)->
    if @cached_reservations?
      this.perform_color_reservations(@cached_reservations)
      return
    $.getJSON("/reservations.json?date=#{date}", (reservations) =>
      @cached_reservations = reservations
      this.perform_color_reservations(reservations)
    )
    return
  perform_color_reservations: (reservations) ->
    user = User.current().get_value("onid")
    for reservation in reservations
      element = $(".bar[data-id=#{reservation.id}]")
      element.removeClass("bar-danger")
      element.addClass("bar-info")
      element.attr("data-action", "cancel")
      if User.current().get_value("staff") == true
        element.attr("data-action", "update")
      if (reservation.user_onid == user || !reservation.user_onid?) && User.current().get_value("staff") == false
        element.attr("data-original-title","Click to Cancel")
      else
        element.data("user-onid", reservation.user_onid)
        element.attr("data-original-title", "#{reservation.user_name}: Click to Update")
  get_date_from_cookie: ->
    result = $.cookie('date')
    unless result?
      min_date = @datepicker.datepicker("option", "minDate").split("/")
      result = "#{min_date[2]}-#{min_date[0]}-#{min_date[1]}"
    result = result.split('-')
    return [parseInt(result[0]),parseInt(result[1]), parseInt(result[2])]
  update_cookie: (year, month, day) ->
    $.cookie('date', "#{year}-#{month}-#{day}", {expires: 30, path: '/'})
  go_to_date: (year, month, day, loading) ->
    @datepicker.datepicker("setDate", "#{month}/#{day}/#{year}")
    current_date = @datepicker.datepicker("getDate")
    @push = false
    @background_loading = loading
    this.selected_date(current_date,@datepicker)
  bind_pop_state: ->
    $(window).on("popstate", (e)=>
      date = location.pathname.split("/").pop().split("-")
      this.go_to_date(date[0], date[1], date[2])
    )
  bind_day_limit_hover: ->
    $("body").on("mouseenter", "span.ui-state-default", ->
      return if $(this).parent().hasClass("has-tooltip")
      active_days = $("a.ui-state-default")
      all_elements = $("#datepicker").find("td")
      last_active_day = $(active_days[0]) unless active_days.length == 0
      parent = last_active_day?.parent()
      if active_days.length == 0 || all_elements.index($(this).parent()) > all_elements.index(last_active_day?.parent())
        parent = $(this).parent()
        advance = Math.abs(moment($("#datepicker").data("max-date")).tz("America/Los_Angeles").diff(moment().tz("America/Los_Angeles").hour(0).minute(0).second(0).subtract(1, 'hour'),'days'))
        parent.tooltip(
          placement: 'bottom'
          trigger: 'hover'
          title: "You can only reserve up to #{advance} days in advance."
          container: 'body'
        )
        parent.tooltip("show")
        parent.addClass("has-tooltip")
    )
