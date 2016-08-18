$(document).on("calendarInitialized", (e) ->
  window.AdminReserveViewManager = new AdminReserveViewManager(e.element)
)
class AdminReserveViewManager
  constructor: (calendar) ->
    return if $(".alternate-admin-view").length == 0 || User.current().get_value("staff") != true
    @modal = $("#modal_skeleton")
    this.handlebars_skeleton()
    $("*[data-action=alternate-view]").click(=> this.initialize_modal())
    @calendar = calendar
    selected_date = moment(calendar.datepicker.datepicker("getDate"))
    today = moment().tz("America/Los_Angeles")
    if(selected_date.day() != today.day() || selected_date.month() != today.month() || selected_date.year() != today.year())
      $("*[data-action=alternate-view]").hide()
    else
      $("*[data-action=alternate-view]").show()
    $(document).on("dayChanged", this.day_changed)
    $(document).on("eventsTruncated", this.day_changed)
  day_changed: (event)=>
    current_day = moment().tz("America/Los_Angeles")
    if(event.day.day() != current_day.day() || event.day.month() != current_day.month() || event.day.year() != current_day.year())
      $("*[data-action=alternate-view]").hide()
      @modal.modal("hide")
    else
      $("*[data-action=alternate-view]").show()
    if @modal.is(':visible') && @modal.css("opacity") != "0" && @modal.find(".modal-title").text() == "Immediate Reservation"
      this.initialize_modal()
  free_bars: ->
    m = this
    current_time = moment().tz("America/Los_Angeles")
    current_min = current_time.minutes()
    current_time.minutes(Math.ceil(current_time.minute()/10)*10)
    # Round up if right on the money.
    current_time.minutes(current_time.minutes()+10) if current_time.minutes() == current_min
    current_time.seconds(0)
    bars = []
    $(".room-data-wrap .bar-success").each ->
      element = $(this)
      return if element.parent().parent().css("display") == "none" # Do not add filtered out items.
      bar_start = moment(element.data("start")).tz("America/Los_Angeles")
      bar_end = moment(element.data("end")).tz("America/Los_Angeles")
      if bar_start <= current_time && bar_end > current_time
        bars.push element
    return bars
  free_bars_object: (availability)->
    objects = []
    for bar in this.free_bars()
      objects.push this.bar_to_object(bar, availability)
    objects = objects.sort (a, b) ->
      diff_a = parseInt(a["duration_number"])
      diff_b = parseInt(b["duration_number"])
      return 1 if diff_b > diff_a
      return -1 if diff_b < diff_a
      return 1 if a["room-name"] > b["room-name"]
      return -1 if a["room-name"] < b["room-name"]
      return 0
    max_duration = parseInt(objects[0]["duration_number"]) if objects.length > 0
    for object in objects
      object["width"] = 400*parseInt(object["duration_number"])/max_duration
    return {'bars': objects}
  bar_to_object: (bar, availability) ->
    object = {}
    room = bar.parent().parent()
    object["room-name"] = room.data("room-name")
    object["room-id"] = room.data("room-id")
    object["start"] = bar.data("start")
    end = bar.data("end")
    if availability[room.data("room-name")]?["availability"]?
      start_time = moment(bar.data("start")).tz("America/Los_Angeles")
      start_time.add(parseInt(availability[room.data("room-name")]["availability"]), "seconds")
      end = start_time.toISOString()
    object["end"] = bar.data("end")
    object["width"] = bar.height()
    # Set duration
    start_time_object = moment(bar.data("start")).tz("America/Los_Angeles")
    end_time_object = moment(end).tz("America/Los_Angeles")
    minute_diff = end_time_object.diff(start_time_object, 'minutes')
    object["duration_number"] = minute_diff
    hour_diff = Math.floor(minute_diff/60)
    minute_diff -= hour_diff*60
    minute_diff = "00" if minute_diff == 0
    object["duration"] = "#{hour_diff}:#{minute_diff}"
    object["end_time_string"] = end_time_object.format("h:mm A")
    return object
  handlebars_skeleton: ->
    return @handlebars_compiled if @handlebars_compiled?
    @handlebars_compiled = Handlebars.compile($(".alternate-admin-view").first().html()) if $(".alternate-admin-view").first().html()?
  initialize_modal: ->
    selected_date = moment(@calendar.datepicker.datepicker("getDate"))
    today = moment().tz("America/Los_Angeles")
    if(selected_date.day() != today.day() || selected_date.month() != today.month() || selected_date.year() != today.year())
      $("*[data-action=alternate-view]").hide()
      @modal.modal("hide")
      return
    element = this.free_bars()[0]
    if element?
      end_time = moment(element.data("start")).tz("America/Los_Angeles")
    else
      end_time = moment().tz("America/Los_Angeles")
    end_time.second(0)
    end_time.minute(Math.ceil(end_time.minute()/10)*10)
    $.getJSON("/availability/all/#{end_time.toISOString()}.json", (result) =>
      @modal.find(".modal-content").html(this.handlebars_skeleton()(this.free_bars_object(result)))
      this.build_modal()
    )
  build_modal: ->
    @modal.on("shown", =>
      $(document).off("focusin.modal")
      @modal.off("shown")
    )
    @modal.modal().css({
      width: '600px',
      'margin-left': ->
        return -($(this).width() / 2);
      }
    )
    window.TooltipManager.set_tooltips()
