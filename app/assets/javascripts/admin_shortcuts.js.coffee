jQuery ->
  window.AdminShortcutsManager = new AdminShortcutsManager
class AdminShortcutsManager
  constructor: ->
    @keycard_field = $("#keycard_entry")
    @modal = $("#modal_skeleton")
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
    return
  bind_user_search: ->