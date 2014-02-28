jQuery ->
  window.ReservationPopupManager = new ReservationPopupManager
class ReservationPopupManager
  constructor: ->
    master = this
    @popup = $("#reservation-popup")
    @reservation_popup = $("#reservation-popup")
    @update_popup = $("#update-popup")
    return if @reservation_popup.length == 0 && @update_popup.length == 0
    @popup = @update_popup if @reservation_popup.length == 0
    @popup_message = Handlebars.compile(@popup.children(".popup-message").html())
    $("body").on("click", "*[data-action=reserve]", (event)->
      master.popup = master.reservation_popup
      element = $(this)
      room_element = element.parent().parent()
      # Truncate start/end times to 10 minute mark.
      start_time = moment(element.data("start")).tz("America/Los_Angeles")
      start_time.second(0)
      start_time.minute(Math.ceil(start_time.minute()/10)*10)
      end_time = moment(element.data("end")).tz("America/Los_Angeles")
      end_time.second(0)
      end_time.minute(Math.ceil(end_time.minute()/10)*10)
      master.element = element
      # Set up popup.
      master.populate_reservation_popup(room_element, start_time, end_time, event)
      event.preventDefault()
    )
    # Set up update popup
    $("body").on("click", "*[data-action=update]", (event) ->
      master.popup = master.update_popup
      element = $(this)
      room_element = element.parent().parent()
      # Truncate start/end times to 10 minute mark.
      start_time = moment(element.data("start")).tz("America/Los_Angeles")
      prev = $(element.prev())
      if prev.hasClass("bar-success")
        start_time = moment(prev.data("start")).tz("America/Los_Angeles")
      start_time.second(0)
      start_time.minute(Math.ceil(start_time.minute()/10)*10)
      end_time = moment(element.data("end")).tz("America/Los_Angeles")
      end_time.second(0)
      end_time.minute(Math.ceil(end_time.minute()/10)*10)
      master.element = element
      # Set up popup.
      master.populate_update_popup(room_element, start_time, end_time, event)
      event.preventDefault()
    )
    @reservation_popup.click (event) ->
      event.stopPropagation() unless $(event.target).data("remote")? || $(event.target).data("action")? || $(event.target).hasClass("ui-slider-handle")
    @reservation_popup.on("touchend", (event) =>
      event.stopPropagation() unless $(event.target).data("remote")? || $(event.target).data("action")? || $(event.target).hasClass("ui-slider-handle")
    )
    @update_popup.click (event) ->
      event.stopPropagation() unless $(event.target).data("remote")? || $(event.target).data("action")? || $(event.target).hasClass("ui-slider-handle")
    @update_popup.on("touchend", (event) =>
      event.stopPropagation() unless $(event.target).data("remote")? || $(event.target).data("action")? || $(event.target).hasClass("ui-slider-handle")
    )
    # Bind Form
    master.prepare_form()
    # Bind popup closers
    this.bind_popup_closers()
    this.admin_binds() if User.current().get_value("staff") == true
  prepare_form: ->
    form = $(".reserver")
    form.on("ajax:beforeSend", this.display_loading)
    form.on("ajax:success", this.display_success_message)
    form.on("ajax:error", this.display_error_message)
  bind_popup_closers: ->
    master = this
    $(".reserver-popup .close-popup a").click((event) =>
      event.preventDefault()
      master.hide_popup()
    )
    $("body").click (event) =>
      this.hide_popup() unless $(event.target).data("remote")? || $(event.target).hasClass("ui-slider-handle")
    $("body").on("touchend", (event) =>
      this.hide_popup() unless $(event.target).data("remote")? || $(event.target).hasClass("ui-slider-handle")
    )
  center_popup: ->
    if $("body").width() <= 480
      @popup.css("height","auto")
      @popup.css("top", "#{$(window).height()/2 - $("#reservation-popup").height()}px")
  reset_center_popup: ->
    if $("body").width() <= 480
      @popup.css("height","100%")
      @popup.css("top", "0px")
  display_success_message: (event, data, status, xhr) =>
    @popup.children(".popup-content").hide()
    @popup.children(".popup-message").show()
    @popup.children(".popup-message").html(@popup_message(data))
    this.center_popup()
    @ignore_popup_hide = true
    window.EventsManager.eventsUpdated()
  display_error_message: (event, xhr, status, error) =>
    errors = xhr.responseJSON
    @popup.children(".popup-message").hide()
    @popup.children(".popup-content").show()
    this.reset_center_popup()
    if errors?["errors"]?
      errors = errors["errors"]
      @popup.find(".popup-content-errors").html(errors.join("<br>"))
      @popup.find(".popup-content-errors").show()
  display_loading: (xhr, settings) =>
    @popup.children(".popup-content").hide()
    popup_message = @popup.children(".popup-message")
    popup_message.show()
    popup_message.text("Reserving...")
    this.center_popup()
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
    result = date.split("+")[0].split("-")
    result.pop() if result.length > 3
    "#{result.join("-").replace("Z","")}-00:00"
  position_popup: (x, y)->
    if(y < window.scrollY)
      y = window.scrollY+10
    # Change behavior for phones
    @popup.attr("style","")
    @popup.show()
    if $("body").width() <= 480
      @popup.css("max-width","none")
      @popup.css("max-height","none")
      @popup.width("100%")
      this.reset_center_popup()
      @popup.css("position", "fixed")
      @popup.css("left",0)
      @popup.css("margin-left",-1)
      @popup.css("margin-top",-1)
    else
      @popup.css("top", y)
      @popup.css("left", x+10)
    return
  populate_reservation_popup: (room_element, start_time, end_time, event) ->
    $(".popup").hide()
    this.hide_popup()
    room_id = room_element.data("room-id")
    room_name = room_element.data("room-name")
    max_reservation = User.current().get_value("maxReservation")
    new_time = this.get_relative_start_time(start_time, end_time, event)
    return if !max_reservation?
    @popup.find("#room-name").text(room_name)
    @popup.find("#reserver_room_id").val(room_id)
    @popup.find("#reserver_start_time").val(start_time.toISOString())
    @popup.find("#reserver_user_onid[type=text]").val("")
    @popup.find("#reserver_user_onid[type=text]").focus()
    $.getJSON("/availability/#{room_id}/#{end_time.toISOString()}.json", (result) =>
      availability = result.availability
      this.build_slider(start_time, end_time, max_reservation, availability, new_time)
      this.position_popup(event.pageX, event.pageY)
      @popup.show()
    )
  get_relative_start_time: (start_time, end_time, event) ->
    offset = (event.offsetY || event.pageY - $(event.target).offset().top)
    offset = Math.floor(offset*3/10)*10
    new_time = start_time.clone().add("minutes", offset)
    if new_time < end_time
      return new_time
    else
      return start_time
  populate_update_popup: (room_element, start_time, end_time, event) ->
    $(".popup").hide()
    this.hide_popup()
    room_id = room_element.data("room-id")
    room_name = room_element.data("room-name")
    max_reservation = User.current().get_value("maxReservation")
    return if !max_reservation?
    @popup.find("#room-name").text(room_name)
    @popup.find("#reserver_room_id").val(room_id)
    @popup.find("#reserver_start_time").val(start_time.toISOString())
    @popup.find("#reserver_user_onid[type=text]").val("")
    @popup.find("#reserver_user_onid[type=text]").focus()
    @popup.find("form").attr("action", "/reservations/#{@element.data("id")}.json")
    @popup.find("form").attr("method", "post")
    $.getJSON("/availability/#{room_id}/#{end_time.toISOString()}.json?blacklist=#{@element.data("id")}", (result) =>
      availability = result.availability
      this.build_slider(start_time, end_time, max_reservation, availability)
      s = moment(@element.data("start")).tz("America/Los_Angeles")
      s.second(0)
      s.minute(Math.ceil(s.minute()/10)*10)
      @slider_element.slider(values: [(s-start_time)/1000/60/10,(end_time-start_time)/1000/60/10])
      this.position_popup(event.pageX, event.pageY)
    )
    $.getJSON("/reservations/#{@element.data("id")}.json", (result) =>
      @popup.find("#reserver_user_onid").val(result.user_onid)
      @popup.find("#reserver_key_card_key").val(result.key_card?.key || "")
      @popup.find("#reserver_description").val(result.description)
      @popup.find("#update-cancel-button").html(result.cancel_string)
      @popup.find("#update-cancel-button a").text("Cancel Reservation")
    )
  build_slider: (start_time, end_time, max_reservation, available_time, new_start_time) ->
    @slider_element = @popup.find(".reservation-slider")
    @start_time = start_time
    @end_time = end_time
    @max_reservation = max_reservation
    maximum = Math.floor(((@end_time - @start_time)/1000/60 + available_time/60)/10)
    @slider_element.slider(
      range: true
      min: 0
      max: maximum
      slide: this.slid
      change: (event, ui)=> this.slid(false, ui)
      values: [0, max_reservation/60/10-1]
    )
    initial_start = 0
    if new_start_time? && User.current().get_value("staff") != true
      initial_start = new_start_time.diff(start_time, 'minutes')/10
      initial_start = 0 if initial_start < 0
    this.slid(1, {values: [0, max_reservation/60/10]})
    @slider_element.slider("values", [initial_start, max_reservation/60/10+initial_start])
    @pickers = []
    m = this
    $(".picker").each ->
      element = $(this)
      timepicker = element.timepicker()
      m.pickers << timepicker
      element.on("blur", (e) -> m.updatedTimeLabel(element, e))
    @popup.show()
  updatedTimeLabel: (target_element, event) =>
    if target_element.attr("id") == "start_picker"
      element_time = @start_time
      index = 0
    else
      element_time = @start_time
      index = 1
    #event.stopPropagation()
    start_time = element_time.clone().tz("America/Los_Angeles")
    input_time = moment("#{start_time.format("YYYY-MM-DD")} #{target_element.val()}", "YYYY-MM-DD h:m:s A").tz("America/Los_Angeles")
    if index == 1 && input_time < @start_time
      input_time.add('days',1)
    difference = Math.floor(input_time.diff(start_time, 'minutes')/10)
    max = @slider_element.slider("option", "max")
    if index == 1
      difference = Math.abs(difference)
    difference = 0 if difference < 0
    difference = max if difference > max
    values = @slider_element.slider("values")
    values[index] = difference
    # Push the other value if it breaks max reservation.
    max_reservation = @max_reservation/60/10
    if index == 0
      if values[1] < values[0]
        values[1] = values[0]+1
      if values[0] > values[1]
        values[0] = values[1]-1
      if values[1] - values[0] > max_reservation
        values[1] = values[0] + max_reservation
    if index == 1
      if values[1] < values[0]
        values[0] = values[1]-1
      if values[0] > values[1]
        values[1] = values[0]+1
      if values[1] - values[0] > max_reservation
        values[0] = values[1] - max_reservation
    @slider_element.slider("values", [values[0], values[1]])
    $(".picker").timepicker()
  slid: (event, ui) =>
    start = ui.values[0]
    end = ui.values[1]
    max_reservation = @max_reservation/60/10
    # Don't allow less than 10 minutes.
    if(end-start < 1 && event != false)
      event?.preventDefault()
      return
    # Force end back if it goes too far
    if end > @slider_element.slider("option","max")
      end = @slider_element.slider("option","max")
    # Force the other slider closer if they get past the maximum reservation time.
    if(end-start > max_reservation && event != false)
      if @slider_element.slider("values")[0] != start
        @slider_element.slider("values",1,start+max_reservation)
        end = start+max_reservation
      else
        @slider_element.slider("values",0,end-max_reservation)
        start = end-max_reservation
    start_time_object = @start_time.clone().tz("America/Los_Angeles")
    end_time_object = @start_time.clone().tz("America/Los_Angeles")
    # Add the 10 minute increments
    start_time_object.add('minutes', start*10)
    end_time_object.add('minutes', end*10)
    @popup.find("#reserver_start_time").val(start_time_object.toISOString())
    @popup.find("#reserver_end_time").val(end_time_object.toISOString())
    # Set labels
    @popup.find(".time-range-label .start-time .picker").val(start_time_object.format("h:mm A"))
    @popup.find(".time-range-label .end-time .picker").val(end_time_object.format("h:mm A"))
    # Set Duration
    minute_diff = end_time_object.diff(start_time_object, 'minutes')
    hour_diff = Math.floor(minute_diff/60)
    minute_diff -= hour_diff*60
    minute_diff = "00" if minute_diff == 0
    @popup.find(".reservation-duration").text("#{hour_diff}:#{minute_diff}")
  # Just for binding the automatic User fillout stuff at the moment.
  # This should probably be factored out somewhere, along with the user query stuff.
  admin_binds: ->
    master = this
    $("*[name='reserver[user_onid]']").blur((e) ->
      id = $(this).val()
      id = id.substring(id.length-9)
      User.find(id: id, callback: master.set_reservation_onid, element: $(this))
    )
    $("*[name='reserver[user_onid]']").keypress((e) ->
      if e.which == 13
        $(this).trigger("blur")
        return false
    )
  set_reservation_onid: (user, element)->
    if user.get_value("onid")?
      element.val(user.get_value("onid"))
      element.parent().parent().next().find("input").trigger("focus")
