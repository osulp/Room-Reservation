jQuery ->
  window.AdminShortcutsManager = new AdminShortcutsManager
class AdminShortcutsManager
  constructor: ->
    @keycard_field = $("#keycard_entry")
    @user_field = $("#user_lookup")
    @modal = $("#modal_skeleton")
    @message = $("#staff-shortcut-message")
    this.bind_keycard_swipe()
    this.bind_user_search()
  bind_keycard_swipe: ->
    @keycard_field.on("blur", => this.keycard_swiped())
    # Bind to enter key.
    @keycard_field.on("keypress", (e) =>
      if e.which == 13
        @keycard_field.trigger("blur")
        this.keycard_swiped()
        e.preventDefault()
    )
  checked_in: (event, xhr, status) =>
    console.log(event)
    console.log(xhr)
    console.log(status)
    return
  keycard_swiped: =>
    @keycard_field.removeClass("bordered")
    keycard_entry = @keycard_field.val()
    return if !keycard_entry? || keycard_entry == ""
    @keycard_field.val("")
    @keycard_field.focus()
    $.post("/admin/key_cards/checkin/#{keycard_entry}", this.keycard_success, 'JSON').fail(this.keycard_failure)
    return
  keycard_success: =>
    @message.removeClass('text-error')
    @message.addClass('text-success')
    @message.text('Key Card Checked In')
    @keycard_field.removeClass("error")
    @keycard_field.addClass("success")
  keycard_failure: (data) =>
    @message.removeClass('text-success')
    @message.addClass('text-error')
    data = data.responseJSON
    if data?["errors"]?
      errors = data["errors"].join(", ")
    else
      errors = "Keycard Not Found"
    @message.text(errors)
    @keycard_field.removeClass("success")
    @keycard_field.addClass("error")
  bind_user_search: ->
    @user_field.on("blur", => this.user_searched())
    # Bind to enter key.
    @user_field.on("keypress", (e) =>
      if e.which == 13
        @user_field.trigger("blur")
        this.user_searched()
        e.preventDefault()
    )
  user_searched: =>
    @user_field.removeClass("bordered")
    user_query = @user_field.val()
    return if !user_query || user_query == ""
    @user_field.val("")
    @user_field.focus()
    $.get("/admin/users/#{user_query}/reservations", (data) =>
      @modal.find(".modal-content").html(data)
      @modal.modal().css({
        width: 'auto',
        'margin-left': ->
          return -($(this).width() / 2);
        }
      )
    )