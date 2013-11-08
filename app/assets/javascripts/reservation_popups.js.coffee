jQuery ->
  window.ReservationPopupManager = new ReservationPopupManager
class ReservationPopupManager
  constructor: ->
    master = this
    @popup = $("#reservation-popup")
    @popup_message = Handlebars.compile(@popup.children(".popup-message").html())
    $("body").on("click", ".bar-success", (event)->
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
    )
    @popup.click (event) ->
      event.stopPropagation() unless $(event.target).data("remote")?
    @popup.on("touchend", (event) =>
      event.stopPropagation() unless $(event.target).data("remote")?
    )
    # Bind Form
    master.prepare_form()
    # Bind popup closers
    this.bind_popup_closers()
    this.admin_binds() if User.current().get_value("staff") == true
  prepare_form: ->
    form = $("#new_reserver")
    form.on("ajax:beforeSend", this.display_loading)
    form.on("ajax:success", this.display_success_message)
    form.on("ajax:error", this.display_error_message)
  bind_popup_closers: ->
    master = this
    @popup.find(".close-popup a").click((event) =>
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
    window.CalendarManager.refresh_view()
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
    $("#reservation-popup #room-name").text(room_name)
    $("#reservation-popup #reserver_room_id").val(room_id)
    $("#reservation-popup #reserver_start_time").val(start_time.toISOString())
    $("#reservation-popup #reserver_user_onid[type=text]").val("")
    $("#reservation-popup #reserver_user_onid[type=text]").focus()
    $.getJSON("/availability/#{room_id}/#{end_time.toISOString()}.json", (result) =>
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
    start_time_object = @start_time.clone().tz("America/Los_Angeles")
    end_time_object = @start_time.clone().tz("America/Los_Angeles")
    # Add the 10 minute increments
    start_time_object.add('minutes', start*10)
    end_time_object.add('minutes', end*10)
    $("#reserver_start_time").val(start_time_object.toISOString())
    $("#reserver_end_time").val(end_time_object.toISOString())
    # Set labels
    $("#reservation-popup .time-range-label .start-time").text(start_time_object.format("h:mm A"))
    $("#reservation-popup .time-range-label .end-time").text(end_time_object.format("h:mm A"))
  # Just for binding the automatic User fillout stuff at the moment.
  # This should probably be factored out somewhere, along with the user query stuff.
  admin_binds: ->
    $("#reserver_user_onid").blur((e) =>
      id = $("#reserver_user_onid").val()
      id = id.substring(id.length-9)
      User.find(id: id, callback: this.set_reservation_onid)
    )
    $("#reserver_user_onid").keypress((e) =>
      if e.which == 13
        $("#reserver_user_onid").trigger("blur")
        return false
    )
  set_reservation_onid: (user)->
    if user.get_value("onid")?
      $("#reserver_user_onid").val(user.get_value("onid"))
      $("#reserver_user_onid").parent().parent().next().find("input").trigger("focus")