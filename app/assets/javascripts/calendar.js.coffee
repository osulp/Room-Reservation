jQuery ->
  window.CalendarManager = new CalendarManager
class CalendarManager
  constructor: ->
    this.initialize_calendar()
  initialize_calendar: ->
    @datepicker = $("#datepicker")
    @datepicker.datepicker(onSelect: this.selected_date, showButtonPanel: true)
    $(document).on("click","button[data-handler=today]",this.go_to_today)
    cached_date = this.get_date_from_cookie()
    @datepicker.datepicker("setDate","#{cached_date[1]}/#{cached_date[2]}/#{cached_date[0]}")
    @date_selected = [cached_date[0], cached_date[1], cached_date[2]]
    this.truncate_to_now()
  go_to_today: =>
    @datepicker.datepicker("setDate","+0")
    current_date = @datepicker.datepicker("getDate")
    this.selected_date(current_date,@datepicker)
    return
  truncate_to_now: =>

    current_time = new Date()
    current_hour = current_time.getHours()
    bar_length = current_hour*60*60/180
    start_offset = $(".room-data-bar").first().offset().top
    hour_elements = $(".tab-content div").filter( -> $(this).data("hour") < current_hour)
    hour_elements.show()
    $("div").filter( -> $(this).data("old-height")?).each (key, item) ->
      $(this).height($(this).data("old-height"))
    return unless [current_time.getFullYear(), current_time.getMonth()+1, current_time.getDate()].toString() == @date_selected.toString()
    $(".room-data").each (key, item) =>
      $(item).data("old-height", $(item).height())
      $(item).height($(item).height() - bar_length)
    $(".bar").each (key, item) =>
      item = $(item)
      start_at = item.offset().top - start_offset
      end_at = item.height()
      if start_at < bar_length
        if end_at > bar_length
          item.height(end_at - bar_length)
        else
          item.remove()
    $(".room-data-bar").height($(".room-data-bar").height()-bar_length)
    hour_elements.hide()
    $("#dayviewTable").data("old-height", $("#dayviewTable").height())
    $("#dayviewTable").height($("#dayviewTable").height() - bar_length)
    return
  selected_date: (dateText, inst) =>
    date = @datepicker.datepicker("getDate")
    @date_selected = [date.getFullYear(), date.getMonth()+1, date.getDate()]
    this.day_changed(date.getFullYear(), date.getMonth()+1, date.getDate())
    return
  day_changed: (year, month, day) =>
    # Set cookies
    this.update_cookie(year, month, day)
    this.load_day(year, month, day)
    # Highlight day on map
    $(".day").removeClass("day-selected")
    $(".day[day=#{day}]").addClass("day-selected")
  load_day: (year, month, day) ->
    $('#loading-spinner').fadeIn()
    cookie_requested = this.get_date_from_cookie()
    console.log("Loading day from cookie #{this.get_date_from_cookie()}")
    $.get("/home/day/#{encodeURIComponent("#{year}-#{month}-#{day}")}", (data) =>
      return unless @date_selected.toString() == [year, month, day].toString()
      new_room_list = $(data)
      for i in [0..new_room_list.length-1]
        div = $(new_room_list[i])
        id = div.attr('id')
        html = div.html()
        $('#' + id).html(html)
      $('#loading-spinner').hide()
      window.FilterManager.apply_filters()
      window.TooltipManager.set_tooltips()
      this.truncate_to_now()
    )
    return
  get_date_from_cookie: ->
    return [parseInt($.cookie('year')), parseInt($.cookie('month')),parseInt($.cookie('day'))]
  update_cookie: (year, month, day) ->
    $.cookie('year', year, { expires: 30 })
    $.cookie('month', month, { expires: 30 })
    $.cookie('day', day, { expires: 30 })