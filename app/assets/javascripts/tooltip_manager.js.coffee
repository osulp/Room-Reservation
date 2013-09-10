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
    if($("#user-info").length == 0)
      $(".bar-success").attr("data-original-title", "Login to Reserve")