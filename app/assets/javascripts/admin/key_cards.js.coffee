jQuery ->
  window.KeyCardFilterManager = new KeyCardFilterManager
class KeyCardFilterManager
  constructor: ->
    @keycards = []
    for keycard in $("tr[data-keycard]")
      element = $(keycard)
      @keycards.push {"key": element.attr('data-keycard'), "element": element}
    @input = $("input#keycard_filter")
    @hit_count = $("span#keycard_filter_hit_count")
    @reset = $("button#keycard_filter_reset")
    @color_class = 'info'

    @input.keypress(this.apply_filters)
    @reset.click(this.clear_filters)
  clear_filters: =>
    @input.val('')
    @input.focus()
    this.apply_filters()
    false
  apply_filters: =>
    key = @input.val()
    if key == ''
      @hit_count.hide()
      $("tr[data-keycard]").removeClass(@color_class)
      return

    hit = 0
    for keycard in @keycards
      if keycard.key.indexOf(key) != -1
        keycard.element.addClass(@color_class)
        hit++
      else
        keycard.element.removeClass(@color_class)
    @hit_count.text hit+" matches"
    @hit_count.show()
