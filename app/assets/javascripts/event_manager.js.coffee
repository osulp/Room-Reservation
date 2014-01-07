class EventsManager
  eventsUpdated: ->
    $.event.trigger({type: "eventsUpdated", time: new Date()})
window.EventsManager = new EventsManager