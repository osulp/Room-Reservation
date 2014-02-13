jQuery ->
  window.TooltipManager = new TooltipManager
class TooltipManager
  constructor: ->
    this.set_tooltips()
  set_tooltips: ->
    $(".tooltip").remove()
    bars = $('.bar')
    return if bars.length == 0
    bars.tooltip({
      placement: 'right',
      container: 'body'
    });
    unless User.current().get_value("onid")?
      $(".bar-success").attr("data-original-title", "Login to Reserve")
      $(".bar-success").attr("data-action", "login")