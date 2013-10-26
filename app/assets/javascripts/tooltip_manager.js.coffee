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
    unless User.current().get_value("onid")?
      $(".bar-success").attr("data-original-title", "Login to Reserve")