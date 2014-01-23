Handlebars.registerHelper "pretty-time-range", (start, end) ->
  format = "MM/DD"
  #format_2 = "MM/DD hh:mm A"
  format_2 = "hh:mm A" # if moment(start).format("MM/DD/YYYY") == moment(end).format("MM/DD/YYYY")
  "#{moment(end).tz("America/Los_Angeles").format(format)} Until <b>#{moment(end).tz("America/Los_Angeles").format(format_2)}</b>"