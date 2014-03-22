jQuery ->
  window.AdminShortcutsManager = new AdminShortcutsManager
class AdminShortcutsManager
  constructor: ->
    @keycard_field = $("#keycard_entry")
    @user_field = $("#user_lookup")
    @modal = $("#modal_skeleton")
    @message = $("#staff-shortcut-message")
    this.bind_keycard_swipe()
    this.bind_keycard_checkout()
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
  bind_keycard_checkout: ->
    master = this
    $('body').on('blur', '.keycard-checkout', ->
      master.keycard_checkout_swiped(this)
    )
    $('body').on('keypress', '.keycard-checkout', (e)->
      if e.which == 13
        $(this).trigger("blur")
        master.keycard_checkout_swiped(this)
        e.preventDefault()
    )
    return
  keycard_checkout_swiped: (field) ->
    field = $(field)
    id = field.data("id")
    keycard_value = field.val()
    return if !keycard_value || !id
    field.val("")
    $.post("/admin/reservations/#{id}/checkout/#{keycard_value}.json", this.keycard_checkout_success, 'JSON').fail(this.keycard_checkout_failure)
    return
  keycard_checkout_success: (data) =>
    this.reload_user(this.show_success)
    return
  show_success: =>
    alert = @modal.find("#modal-alert")
    alert.removeClass("alert-error")
    alert.addClass("alert-success")
    alert.html("Key Card Checked Out")
    alert.show()
    return
  keycard_checkout_failure: (data) =>
    alert = @modal.find("#modal-alert")
    alert.removeClass("alert-success")
    alert.addClass("alert-error")
    data = data.responseJSON
    if data?["errors"]?
      alert.html(data["errors"].join("<br>"))
    else
      alert.html("Unable to find given key card.")
    alert.show()
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
    @keycard_field.focus()
    return
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
    @keycard_field.focus()
    return
  bind_user_search: ->
    @user_field.on("blur", => this.user_searched())
    # Bind to enter key.
    @user_field.on("keypress", (e) =>
      if e.which == 13
        @user_field.trigger("blur")
        this.user_searched()
        e.preventDefault()
    )
    $(document).on("eventsUpdated", =>
      this.reload_user(->) if @modal.is(':visible')
    )
  user_searched: =>
    @user_field.removeClass("bordered")
    user_query = @user_field.val()
    return if !user_query || user_query == ""
    user_query = user_query.replace(/^11([0-9]{9})/, '$1')
    @user_field.val("")
    @user_field.focus()
    this.load_user(user_query)
  reload_user: (callback)=>
    user_query = @modal.find(".modal-content").data("user")
    this.load_user(user_query, callback) if user_query?
    return
  load_user: (user_query, callback) =>
    $.get("/admin/users/#{user_query}/reservations", (data) =>
      @modal.find(".modal-content").data("user", user_query)
      @modal.find(".modal-content").html(data)
      callback?()
      @modal.on("shown", =>
        $(document).off("focusin.modal")
        @modal.off("shown")
      )
      @modal.modal().css({
          width: 'auto',
          'margin-left': ->
            return -($(this).width() / 2);
        }
      )
    )
    return
