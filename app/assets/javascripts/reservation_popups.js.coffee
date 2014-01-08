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
      master.position_popup(event.pageX, event.pageY)
      master.populate_reservation_popup(room_element, start_time, end_time)
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
      master.position_popup(event.pageX, event.pageY)
      master.populate_update_popup(room_element, start_time, end_time)
      event.preventDefault()
    )
    @reservation_popup.click (event) ->
      event.stopPropagation() unless $(event.target).data("remote")? || $(event.target).data("action")?
    @reservation_popup.on("touchend", (event) =>
      event.stopPropagation() unless $(event.target).data("remote")? || $(event.target).data("action")?
    )
    @update_popup.click (event) ->
      event.stopPropagation() unless $(event.target).data("remote")? || $(event.target).data("action")?
    @update_popup.on("touchend", (event) =>
      event.stopPropagation() unless $(event.target).data("remote")? || $(event.target).data("action")?
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
      this.hide_popup() unless $(event.target).data("remote")?
    $("body").on("touchend", (event) =>
      this.hide_popup() unless $(event.target).data("remote")?
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
    @popup.show()
    # Change behavior for phones
    @popup.attr("style","")
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
      @popup.offset({top: y, left: x+10})
    @popup.hide()
  populate_reservation_popup: (room_element, start_time, end_time) ->
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
    $.getJSON("/availability/#{room_id}/#{end_time.toISOString()}.json", (result) =>
      availability = result.availability
      this.build_slider(start_time, end_time, max_reservation, availability)
    )
  populate_update_popup: (room_element, start_time, end_time) ->
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
      this.slid(1, {values: [(s-start_time)/1000/60/10,(end_time-start_time)/1000/60/10]})
    )
    $.getJSON("/reservations/#{@element.data("id")}.json", (result) =>
      @popup.find("#reserver_user_onid").val(result.user_onid)
      @popup.find("#reserver_key_card_key").val(result.key_card?.key? || "")
      @popup.find("#reserver_description").val(result.description)
      @popup.find("#update-cancel-button").html(result.cancel_string)
      @popup.find("#update-cancel-button a").text("Cancel Reservation")
    )
  build_slider: (start_time, end_time, max_reservation, available_time) ->
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
    start_time_object = @start_time.clone().tz("America/Los_Angeles")
    end_time_object = @start_time.clone().tz("America/Los_Angeles")
    # Add the 10 minute increments
    start_time_object.add('minutes', start*10)
    end_time_object.add('minutes', end*10)
    @popup.find("#reserver_start_time").val(start_time_object.toISOString())
    @popup.find("#reserver_end_time").val(end_time_object.toISOString())
    # Set labels
    @popup.find(".time-range-label .start-time").text(start_time_object.format("h:mm A"))
    @popup.find(".time-range-label .end-time").text(end_time_object.format("h:mm A"))
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