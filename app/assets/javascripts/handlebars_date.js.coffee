Handlebars.registerHelper "pretty-time-range", (start, end) ->
  format = "MM/DD"
  format_2 = "MM/DD HH:mm"
  format_2 = "HH:mm" if moment(start).format("MM/DD/YYYY") == moment(end).format("MM/DD/YYYY")
  "#{moment(start).tz("America/Los_Angeles").format(format)} Until <b>#{moment(end).tz("America/Los_Angeles").format(format_2)}</b>"