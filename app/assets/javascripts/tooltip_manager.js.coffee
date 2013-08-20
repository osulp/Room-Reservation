jQuery ->
  window.TooltipManager = new TooltipManager
class TooltipManager
  constructor: ->
    this.set_tooltips()
  set_tooltips: ->
    $(".tooltip").remove()
    $('.bar').tooltip({
      placement: 'right',
      container: 'body'
    });