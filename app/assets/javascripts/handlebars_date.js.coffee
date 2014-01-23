Handlebars.registerHelper "pretty-time-range", (start, end) ->
  format = "MM/DD"
  format_2 = "HH:mm"
  "#{moment(end).tz("America/Los_Angeles").format(format)} Until <b>#{moment(end).tz("America/Los_Angeles").format(format_2)}</b>"