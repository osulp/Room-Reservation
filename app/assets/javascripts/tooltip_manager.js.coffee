jQuery ->
  window.TooltipManager = new TooltipManager
class TooltipManager
  constructor: ->
    this.set_tooltips()
  set_tooltips: ->
    $(".tooltip").remove()
    $("*[data-toggle=tooltip]").tooltip()
    bars = $('.bar')
    return if bars.length == 0
    bars.tooltip({
      placement: 'right',
      container: 'body'
    });
    $(".bar-warning").attr("data-original-title", "Can't Reserve in Past")
    unless User.current().get_value("onid")?
      $(".bar-success").attr("data-original-title", "Login to Reserve")
      $(".bar-success").attr("data-action", "login")
