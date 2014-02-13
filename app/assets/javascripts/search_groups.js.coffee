jQuery ->
  window.SearchGroupsAdmin = new SearchGroupsAdmin
class SearchGroupsAdmin
  constructor: ->
    this.bind_elements()
    @modal = $("#modal_skeleton")
  bind_elements: ->
    master = this
    $('#search-groups').click((event) -> master.show_search_modal(this, event))
  show_search_modal: (element, event) ->
    event.preventDefault()
    @modal.find('.modal-title').text("Find Your Group")
    $.get('/reservations/upcoming', (data) =>
      this.populate_modal($(data))
    )
  populate_modal: (data)->
    @modal.find('.modal-body').html(data.attr("id", "group-search-modal-content").wrap('<div>').parent().html())
    @modal.modal().css({
        width: 'auto',
        'margin-left': ->
          return -($(this).width() / 2);
      }
    )
    options = {
      valueNames: ['description', 'room', 'start_time', 'end_time'],
      page: 10,
      plugins: [
        ListFuzzySearch({}),
        ListPagination({paginationClass: 'paginatingList'})
      ]
    }
    @list_object = new List('group-search-modal-content', options)