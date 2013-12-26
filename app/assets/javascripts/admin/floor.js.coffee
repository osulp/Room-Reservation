jQuery ->
  $("*[data-trigger-floor]").change(->
    floors = $(this).data("trigger-floor").toString().split(",")
    $("*[data-floor]").prop("checked", false)
    $("*[data-trigger-floor]:not('##{$(this).attr("id")}')").prop("checked", false)
    floors = $.map(floors, (floor)-> "*[data-floor=#{floor}]").join(",")
    property = $(this).prop('checked')
    $(floors).prop("checked", property)
  )
  $("*[data-floor]").click(->
    $("*[data-trigger-floor]").prop('checked', false)
  )