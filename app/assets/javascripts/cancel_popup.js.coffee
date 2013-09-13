jQuery ->
  window.CancelPopupManager = new CancelPopupManager
class CancelPopupManager
  constructor: ->
    master = this
    @popup = $("#cancel-popup")
    $("body").on("click", ".bar-info", (event)->
      element = $(this)
      room_element = element.parent().parent()
      # Truncate start/end times to 10 minute mark.
      @start_time = new Date(master.parse_date_string(element.data("start")))
      @start_time.setTime(@start_time.getTime() + @start_time.getTimezoneOffset()*60*1000)
      @end_time = new Date(master.parse_date_string(element.data("end")))
      @end_time.setTime(@end_time.getTime() + @end_time.getTimezoneOffset()*60*1000)
      # Set up popup.
      master.position_popup(event.pageX, event.pageY)
      master.populate_cancel_popup(room_element, @start_time, @end_time)
      event.stopPropagation()
    )
    @popup.click (event) ->
      event.stopPropagation() unless $(event.target).data("remote")?
    $("body").click (event) =>
      this.hide_popup() unless $(event.target).data("remote")?
    # Bind popup closers
    this.bind_popup_closers()
  bind_popup_closers: ->
    master = this
    @popup.find(".close-popup a").click((event) =>
      event.preventDefault()
      master.hide_popup()
    )
  display_success_message: (event, data, status, xhr) =>
    @popup.children(".popup-content").hide()
    @popup.children(".popup-message").show()
    @popup.children(".popup-message").text("This reservation has been cancelled!")
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
    @popup.children(".popup-message").text("Cancelling...")
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
    result.join("-")
  position_popup: (x, y)->
    @popup.show()
    @popup.offset({top: y, left: x+10})
    @popup.hide()
  populate_cancel_popup: (room_element, start_time, end_time) ->
    this.hide_popup()
    room_id = room_element.data("room-id")
    room_name = room_element.data("room-name")
    $("#cancel-popup .room-name").text(room_name)
    $("#cancel-popup .reservation_room_id").val(room_id)
    $("#cancel-popup .start-time").text(this.form_time_string(start_time))
    $("#cancel-popup .end-time").text(this.form_time_string(end_time))
    @popup.show()
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