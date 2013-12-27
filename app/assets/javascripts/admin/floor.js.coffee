jQuery ->
  $("*[data-trigger-floor]").change(->
    check_room(this)
  )
  $("*[data-floor]").click(->
    sync_room_filters(this)
  )
  check_rooms()
  $(".datepicker").datepicker(
    showButtonPanel: true
    dateFormat: 'yy-mm-dd'
  )
check_rooms = ->
  $("*[data-floor]").each ->
    sync_room_filters(this)
sync_room_filters = (room) ->
  $("#all_rooms").prop('checked', false)
  result = $("*[data-floor=#{$(room).data("floor")}]").length == $("*[data-floor=#{$(room).data("floor")}]:checked").length
  $("*[data-trigger-floor=#{$(room).data("floor")}]").prop('checked', result)
  $("#all_rooms").prop('checked', $("*[data-floor]").length == $("*[data-floor]:checked").length)
check_room = (room) ->
  floors = $(room).data("trigger-floor").toString().split(",")
  floor_list = floors
  floors = $.map(floors, (floor)-> "*[data-floor=#{floor}]").join(",")
  trigger_floors = $.map(floor_list, (floor)-> "*[data-trigger-floor=#{floor}]").join(",")
  property = $(room).prop('checked')
  $(floors).prop("checked", property)
  $(trigger_floors).prop("checked", property)
  result = $("*[data-floor]").length == $("*[data-floor]:checked").length
  $("#all_rooms").prop('checked', result)