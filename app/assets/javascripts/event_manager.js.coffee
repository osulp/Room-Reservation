class EventsManager
  eventsUpdated: ->
    $.event.trigger({type: "eventsUpdated", time: new Date()})
  dayChanged: (year, month, day)->
    $.event.trigger({type: "dayChanged", time: new Date(), day: moment("#{year}-#{month}-#{day}","YYYY-MM-DD").tz("America/Los_Angeles")})
window.EventsManager = new EventsManager
