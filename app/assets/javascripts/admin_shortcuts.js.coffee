jQuery ->
  window.AdminShortcutsManager = new AdminShortcutsManager
class AdminShortcutsManager
  constructor: ->
    @keycard_field = $("#keycard_entry")
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
  keycard_swiped: ->
    @keycard_field.val("")
  bind_user_search: ->