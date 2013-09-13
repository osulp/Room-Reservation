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
    )
    @popup.click (event) ->
      event.stopPropagation() unless $(event.target).data("remote")?
    $("body").click (event) =>
      this.hide_popup() unless $(event.target).data("remote")?
    # Bind Form
    master.prepare_form()
    # Bind popup closers
    this.bind_popup_closers()
  prepare_form: ->
    form = $("#new_reservation")
    form.on("ajax:beforeSend", this.display_loading)
    form.on("ajax:success", this.display_success_message)
    form.on("ajax:error", this.display_error_message)
  bind_popup_closers: ->
    master = this
    @popup.find(".close-popup a").click((event) =>
      event.preventDefault()
      master.hide_popup()
    )
  display_success_message: (event, data, status, xhr) =>
    @popup.children(".popup-content").hide()
    @popup.children(".popup-message").show()
    @popup.children(".popup-message").text("Your reservation has been made! Check your ONID email for details.")
    @ignore_popup_hide = true
    window.CalendarManager.refresh_view()
  display_error_message: (event, xhr, status, error) =>
    errors = xhr.responseJSON
    @popup.children(".popup-message").hide()
    @popup.children(".popup-content").show()
    if errors["errors"]?
      errors = errors["errors"]
      @popup.find(".popup-content-errors").html(errors.join("<br>"))
      @popup.find(".popup-content-errors").show()
  display_loading: (xhr, settings) =>
    @popup.children(".popup-content").hide()
    @popup.children(".popup-message").show()
    @popup.children(".popup-message").text("Reserving...")
  hide_popup: ->
    if @ignore_popup_hide
      @ignore_popup_hide = false
      return
    @popup.hide()
    @popup.children(".popup-content").show()
    @popup.children(".popup-message").hide()
    @popup.find(".popup-content-errors").html("")
    @popup.find(".popup-content-errors").hide()
  parse_date_string: (date) ->
    result = date.split("-")
    result.pop() if result.length > 3
    "#{result.join("-")}-00:00"
  position_popup: (x, y)->
    @popup.show()
    @popup.offset({top: y, left: x+10})
    @popup.hide()
  populate_reservation_popup: (room_element, start_time, end_time) ->
    $(".popup").hide()
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
    # Hack to remove timezone information.
    start_time_object = start_time_object.toLocalISOString().split("-")
    start_time_object.pop()
    start_time_object = start_time_object.join("-")
    end_time_object = end_time_object.toLocalISOString().split("-")
    end_time_object.pop()
    end_time_object = end_time_object.join("-")
    $("#reservation_start_time").val(start_time_object)
    $("#reservation_end_time").val(end_time_object)
    # Set labels
    $("#reservation-popup .time-range-label .start-time").text(start_time)
    $("#reservation-popup .time-range-label .end-time").text(end_time)
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