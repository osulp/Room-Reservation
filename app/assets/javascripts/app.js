$(function() {
	$('#datepicker')
		.Calendar({'weekStart': 7})
		.on('changeDay', function(event){
			load_day(event.year, event.month, event.day);
		});
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

function load_day(year, month, day) {
	$.cookie('year', year, { expires: 30 })
	$.cookie('month', month, { expires: 30 })
	$.cookie('day', day, { expires: 30 })
	$('#loading-spinner').fadeIn();
	$.get('?ajax', function (data) {
		var new_room_list = $(data);
		for (var i = 0; i < new_room_list.length; i++) {
			var div = $(new_room_list[i]);
			var id = div.attr('id');
			var html = div.html();
			$('#' + id).html(html);
		};
		init_bar_tooltip();
		filter_rooms();
		$('#loading-spinner').fadeOut();
	});
}
