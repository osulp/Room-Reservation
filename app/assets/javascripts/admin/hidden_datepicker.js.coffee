jQuery ->
  window.HiddenDatepickerManager = new HiddenDatepickerManager
class HiddenDatepickerManager
  constructor: ->
    $(".hidden-datepicker").datepicker(
      dateFormat: 'yy-mm-dd'
      onSelect: this.selected
    )
    $("a[data-trigger]").click( (e) ->
      element = $("##{$(this).data('trigger')}")
      element.datepicker("show")
      e.preventDefault()
    )
  selected: (dateText) ->
    link = $(this).siblings("a[data-trigger]").attr("href").replace("FILLER", dateText)
    window.location = link