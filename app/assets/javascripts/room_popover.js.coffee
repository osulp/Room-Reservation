jQuery ->
  $('#dayviewTable').on('click', '.room-name', (event) ->
    $('.room-name').not(this).popover('hide')
    $(this).popover('toggle')
    event.stopPropagation()
  )
  $('body').on('click', '.popover-content', (event) ->
    event.stopPropagation()
  )
  $('body').on('click', '*:not(.room-name):not(.popover-content)', ->
    $('.room-name').popover('hide')
  )
  $('#dayviewTable').popover({html: true, selector: '.room-name', trigger: 'manual', placement: 'bottom', container: 'body'})
