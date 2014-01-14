jQuery ->
  $('#dayviewTable').on('click', '.room-name', () ->
    $('.room-name').not(this).popover('hide')
    $(this).popover('toggle')
  )
  $('#tabs-floor ul').on('click', 'a', () ->
    $('.room-name').popover('hide')
  )
  $('#dayviewTable').popover({html: true, selector: '.room-name', trigger: 'manual', placement: 'bottom', container: 'body'})
