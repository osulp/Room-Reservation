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
  go_to_today: =>
    @datepicker.datepicker("setDate","+0")
    current_date = @datepicker.datepicker("getDate")
    this.selected_date(current_date,@datepicker)
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
    $.get('?ajax', (data) =>
      return unless @date_selected.toString() == [year, month, day].toString()
      new_room_list = $(data)
      for i in [0..new_room_list.length-1]
        div = $(new_room_list[i])
        id = div.attr('id')
        html = div.html()
        $('#' + id).html(html)
      $('#loading-spinner').fadeOut()
      window.FilterManager.apply_filters()
    )
    return
  get_date_from_cookie: ->
    return [parseInt($.cookie('year')), parseInt($.cookie('month')),parseInt($.cookie('day'))]
  update_cookie: (year, month, day) ->
    $.cookie('year', year, { expires: 30 })
    $.cookie('month', month, { expires: 30 })
    $.cookie('day', day, { expires: 30 })