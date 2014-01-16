jQuery ->
  $('#dayviewTable').on('click', '.room-name', (event) ->
    $('.room-name').not(this).popover('hide')
    $(this).popover('toggle')
    event.stopPropagation()
  )
  $('body').on('click', (event) ->
    $('.room-name').popover('hide') unless $(event.target).hasClass('popover-content') || $(event.target).hasClass('room-name')
  )
  $('#dayviewTable').popover({html: true, selector: '.room-name', trigger: 'manual', placement: 'bottom', container: 'body'})
