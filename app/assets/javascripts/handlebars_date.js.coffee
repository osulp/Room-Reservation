Handlebars.registerHelper "pretty-time-range", (start, end) ->
  format = "MM/DD hh:mm A"
  format_2 = "MM/DD hh:mm A"
  format_2 = "hh:mm A" if moment(start).format("MM/DD/YYYY") == moment(end).format("MM/DD/YYYY")
  "#{moment(start).format(format)} - #{moment(end).format(format)}"