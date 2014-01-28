jQuery ->
  if $("body").width() > 480
    jQuery(".popup").draggable handle:".popover-title", containment: 'body'
