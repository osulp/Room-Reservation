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
    date = @datepicker.datepicker("getDate")
    @date_selected = [date.getFullYear(), date.getMonth()+1, date.getDate()]
    this.truncate_to_now()
    this.color_reservations("#{@date_selected[0]}-#{@date_selected[1]}-#{@date_selected[2]}")
  go_to_today: =>
    @datepicker.datepicker("setDate","+0")
    current_date = @datepicker.datepicker("getDate")
    this.selected_date(current_date,@datepicker)
    return
  truncate_to_now: =>
    start_time = new Date($(".room-data-wrap").data("start"))
    current_time = new Date()
    compare_time = new Date(start_time.getTime())
    compare_time.setDate(current_time.getDate())
    compare_time.setMonth(current_time.getMonth())
    compare_time.setFullYear(current_time.getFullYear())
    difference = current_time - compare_time
    current_hour = Math.floor(difference/1000/60/60)
    bar_length = current_hour*60*60/180
    hour_elements = $(".tab-content div").filter( -> $(this).data("hour") < current_hour)
    hour_elements.show()
    $("div").filter( -> $(this).data("old-height")?).each (key, item) ->
      $(this).height($(this).data("old-height"))
    return if current_time < start_time || (current_time - start_time) > 24*60*60*1000
    $(".tab-pane").show()
    $(".room-data").each (key, item) =>
      $(item).data("old-height", $(item).height())
      $(item).height($(item).height() - bar_length)
    $(".bar").each (key, item) =>
      item = $(item)
      start_offset = item.parent().offset().top
      start_at = item.offset().top - start_offset
      end_at = item.height()+start_at
      if start_at < bar_length
        if end_at > bar_length
          if(item.data("start")? && item.hasClass("bar-success"))
            new_time = new Date(current_time.getTime())
            new_time.setHours(0)
            new_time.setSeconds(0)
            new_time.setMinutes(Math.ceil(new_time.getMinutes()/10)*10)
            new_time.setTime(new_time.getTime() + current_hour*60*60*1000)
            item.data("start",new_time.toLocalISOString())
            item.attr("data-start", new_time.toLocalISOString())
          item.height(end_at - bar_length)
        else
          item.data("remove", true)
    $(".bar").filter(-> $(this).data("remove") == true).remove()
    $(".room-data-bar").height($(".room-data-bar").height()-bar_length)
    hour_elements.hide()
    $("#dayviewTable").data("old-height", $("#dayviewTable").height())
    $("#dayviewTable").height($("#dayviewTable").height() - bar_length)
    $(".tab-pane").attr("style",null)
    return
  refresh_view: ->
    current_date = @datepicker.datepicker("getDate")
    this.selected_date(current_date,@datepicker)
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
    $('#loading-spinner').show()
    cookie_requested = this.get_date_from_cookie()
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
      this.color_reservations("#{year}-#{month}-#{day}")
      $(".popup").hide()
    )
    return
  color_reservations: (date)->
    $.getJSON("/reservations?date=#{date}", (reservations) =>
      for reservation in reservations
        element = $("*[data-id=#{reservation.id}]")
        element.removeClass("bar-danger")
        element.addClass("bar-info")
        element.attr("data-original-title","Click to Cancel")
    )
    return
  get_date_from_cookie: ->
    return [parseInt($.cookie('year')), parseInt($.cookie('month')),parseInt($.cookie('day'))]
  update_cookie: (year, month, day) ->
    $.cookie('year', year, { expires: 30 })
    $.cookie('month', month, { expires: 30 })
    $.cookie('day', day, { expires: 30 })