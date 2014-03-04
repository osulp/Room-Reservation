jQuery ->
  window.FayeManager = new FayeManager
class FayeManager
  constructor: ->
    return if $("#datepicker").length == 0
    @client = new Faye.Client($("body").data("push-server"))
    date_selected = window.CalendarManager.date_selected
    this.subscribe_to_date("#{date_selected[0]}-#{date_selected[1]}-#{date_selected[2]}")
  subscribe_to_date: (date) ->
    @current_subscription?.cancel()
    @current_subscription = @client.subscribe("/messages/date/#{date}", (data) ->
      window.CalendarManager.background_loading = true
      window.CalendarManager.cached_reservations = null
      window.CalendarManager.populate_calendar(data)
      day = moment("#{date}","YYYY-MM-DD").tz("America/Los_Angeles")
      $.event.trigger({type: "fayeUpdated", time: new Date(), day: day})
    )
