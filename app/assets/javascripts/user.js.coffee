class @User
  @current: ->
    new User()
  @find: (options) ->
    options = options || {}
    id = options['id']
    callback = options['callback']
    $.getJSON("/users/#{id}", (data) =>
      user = new User(data)
      callback(user)
    )
  constructor: (data)->
    @data_object = data || {}
    this.populate_data_object() unless data?
  populate_data_object: ->
    @data_object = $("#user-info").data()
    @data_object ||= {}
  get_value: (key) ->
    @data_object[key]