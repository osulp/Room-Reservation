jQuery ->
  window.AdminReserveViewManager = new AdminReserveViewManager
class AdminReserveViewManager
  constructor: ->
    @modal = $("#modal_skeleton")
    this.handlebars_skeleton()
  free_bars: ->
    m = this
    current_time = moment().tz("America/Los_Angeles")
    current_time.minutes(Math.ceil(current_time.minute()/10)*10+10)
    current_time.seconds(0)
    bars = []
    $(".room-data-wrap .bar-success").each ->
      element = $(this)
      bar_start = moment(element.data("start")).tz("America/Los_Angeles")
      bar_end = moment(element.data("end")).tz("America/Los_Angeles")
      if bar_start <= current_time && bar_end > current_time
        bars.push element
    return bars
  free_bars_object: ->
    objects = []
    for bar in this.free_bars()
      objects.push this.bar_to_object(bar)
    objects = objects.sort (a, b) ->
      diff_a = moment(a["end"]).tz("America/Los_Angeles").diff(moment(a["start"]).tz("America/Los_Angeles"), 'minutes')
      diff_b = moment(b["end"]).tz("America/Los_Angeles").diff(moment(b["start"]).tz("America/Los_Angeles"), 'minutes')
      diff_b > diff_a ? 1 : ((diff_b < diff_a) ? -1 : 0)
    return {'bars': objects}
  bar_to_object: (bar) ->
    object = {}
    room = bar.parent().parent()
    object["room-name"] = room.data("room-name")
    object["room-id"] = room.data("room-id")
    object["start"] = bar.data("start")
    object["end"] = bar.data("end")
    object["width"] = bar.height()
    # Set duration
    start_time_object = moment(bar.data("start")).tz("America/Los_Angeles")
    end_time_object = moment(bar.data("end")).tz("America/Los_Angeles")
    minute_diff = end_time_object.diff(start_time_object, 'minutes')
    hour_diff = Math.floor(minute_diff/60)
    minute_diff -= hour_diff*60
    minute_diff = "00" if minute_diff == 0
    object["duration"] = "#{hour_diff}:#{minute_diff}"
    return object
  handlebars_skeleton: ->
    return @handlebars_compiled if @handlebars_compiled?
    @handlebars_compiled = Handlebars.compile($(".alternate-admin-view").first().html())
  build_modal: ->
    @modal.find(".modal-content").html(this.handlebars_skeleton()(this.free_bars_object()))
    @modal.modal().css({
      width: 'auto',
      'margin-left': ->
        return -($(this).width() / 2);
      }
    )
    window.TooltipManager.set_tooltips()
  build_view: ->
