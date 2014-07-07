jQuery ->
  window.PatronModeManager = new PatronModeManager
class PatronModeManager
  constructor: ->
    return if $("#patron_mode").length < 1
    $("#patron_mode").click(this.patron_mode_toggle)
    this.update_patron_mode()
  patron_mode_toggle: ->
    element = $(this)
    $.post("/admin/patron_mode/#{"#{element.is(':checked')}"}.json", ->
      window.EventsManager.eventsUpdated()
    )
  update_patron_mode: ->
    $.getJSON("/admin/patron_mode.json", (data)->
      $("#patron_mode").prop('checked', data.status)
    )
