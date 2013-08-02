$(function() {
	$('#room-filters input').on('click', room_filters_onclick);
	init_bar_tooltip();
});

function init_bar_tooltip() {
	$('div.progress div.bar').tooltip({
		placement: 'right',
		container: 'body'
	})
}

function room_filters_onclick(e) {
	if($(this).attr('id') == 'filter_all')
		$('#filters input:checked').prop('checked', '')
	else
		$('#filter_all').prop('checked', '')
	filter_rooms()
}

function filter_rooms() {
	var all = !!$('#filter_all').prop('checked')
	var chosen = $('#filters input:checked').map(function (i, d) { return '.room-filter-' + d.value; }).toArray().join('')
	if(all || chosen.length == 0)
		$('.room-data').removeClass('fadeout')
	else {
		$('.room-data').not(chosen).addClass('fadeout')
		$('.room-data' + chosen).removeClass('fadeout')
	}
}