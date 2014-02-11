jQuery ->
  $("input.add-key[type=submit]").click (e)->
    e.preventDefault()
    value = $("#new-key").val()
    return if value == "" || !value?
    console.log("New value: #{value}")
    sample_input = $("input[name='setting[value][default]']").clone()
    sample_input.attr("id", sample_input.attr("id").replace("default", value))
    sample_input.attr("name", sample_input.attr("name").replace("default", value))
    html = $("<tr><td class='span4'>#{value}</td><td></td></tr>")
    html.find("td:last").append(sample_input)
    $(this).parent().parent().before(html)
  $("td.closing a.close").click (e) ->
    e.preventDefault()
    element = $(this).parent().parent()
    input = element.find("input")
    $(this).parent().parent().remove()