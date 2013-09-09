jQuery ->
  window.ReservationPopupManager = new ReservationPopupManager
class ReservationPopupManager
  constructor: ->
    master = this
    @popup = $("#reservation-popup")
    $("body").on("click", ".bar-success", (event)->
      element = $(this)
      room_element = element.parent().parent()
      # Truncate start/end times to 10 minute mark.
      start_time = new Date(master.parse_date_string(element.data("start")))
      start_time.setTime(start_time.getTime() + start_time.getTimezoneOffset()*60*1000)
      start_time.setSeconds(0)
      start_time.setMinutes(Math.ceil(start_time.getMinutes()/10)*10)
      end_time = new Date(master.parse_date_string(element.data("end")))
      end_time.setTime(end_time.getTime() + end_time.getTimezoneOffset()*60*1000)
      end_time.setSeconds(0)
      end_time.setMinutes(Math.ceil(end_time.getMinutes()/10)*10)
      # Set up popup.
      master.position_popup(event.pageX, event.pageY)
      master.populate_reservation_popup(room_element, start_time, end_time)
      window.start_time = start_time
    )
    @popup.click (event) ->
      event.stopPropagation() unless $(event.target).data("remote")?
    $("body").click (event) =>
      this.hide_popup() unless $(event.target).data("remote")?
    # Bind to the form submission link
    $("#data")
  prepare_parameters: (event, xhr, settings) ->
    console.log event
    console.log xhr
    console.log settings
    form_id = $(this).attr("data-form")
    attributes = $("##{form_id}").serialize()
    event.data = "#{attributes}"
  hide_popup: ->
    @popup.hide()
    @popup.children(".popup-content").show()
    @popup.children(".popup-message").hide()
  parse_date_string: (date) ->
    result = date.split("-")
    result.pop() if result.length > 3
    result.join("-")
  position_popup: (x, y)->
    @popup.show()
    @popup.offset({top: y, left: x+10})
    @popup.hide()
  populate_reservation_popup: (room_element, start_time, end_time) ->
    this.hide_popup()
    room_id = room_element.data("room-id")
    room_name = room_element.data("room-name")
    max_reservation = $("#user-info").data("max-reservation")
    return if !max_reservation?
    $("#reservation-popup #room-name").text(room_name)
    $("#reservation-popup #reservation_room_id").val(room_id)
    $("#reservation-popup #reservation_start_time").val(start_time)
    $.getJSON("/availability/#{room_id}/#{encodeURIComponent(end_time.toISOString()).split(".")[0]+"z"}.json", (result) =>
      availability = result.availability
      this.build_slider(start_time, end_time, max_reservation, availability)
    )
  build_slider: (start_time, end_time, max_reservation, available_time) ->
    @slider_element = $("#reservation-slider")
    @start_time = start_time
    @end_time = end_time
    @max_reservation = max_reservation
    maximum = Math.floor(((@end_time - @start_time)/1000/60 + available_time/60)/10)
    @slider_element.slider(
      range: true
      min: 0
      max: maximum
      slide: this.slid
      values: [0, max_reservation/60/10-1]
    )
    this.slid(1, {values: [0, max_reservation/60/10]})
    @popup.show()
  slid: (event, ui) =>
    start = ui.values[0]
    end = ui.values[1]
    max_reservation = @max_reservation/60/10
    # Don't allow less than 10 minutes.
    if(end-start < 1)
      event.preventDefault()
      return
    # Force end back if it goes too far
    if end > @slider_element.slider("option","max")
      end = @slider_element.slider("option","max")
    # Force the other slider closer if they get past the maximum reservation time.
    if(end-start > max_reservation)
      if @slider_element.slider("values",0) != start
        @slider_element.slider("values",1,start+max_reservation)
        end = start+max_reservation
      else
        @slider_element.slider("values",0,end-max_reservation)
        start = end-max_reservation
    start_time_object = new Date(@start_time.getTime() + start*10*60*1000)
    end_time_object = new Date(@start_time.getTime() + end*10*60*1000)
    start_time = this.form_time_string(start_time_object)
    end_time = this.form_time_string(end_time_object)
    $("#reservation_start_time").val(start_time_object.toISOString())
    $("#reservation_end_time").val(end_time_object.toISOString())
    $("#time-range-label #start-time").text(start_time)
    $("#time-range-label #end-time").text(end_time)
  form_time_string: (date) ->
    meridian = "AM"
    hours = date.getHours()
    if(hours >= 12)
      hours -= 12
      meridian = "PM"
    hours = 12 if hours == 0
    minutes = date.getMinutes()
    minutes = "0#{minutes}" if minutes < 10
    seconds = date.getSeconds()
    return "#{hours}:#{minutes} #{meridian}"