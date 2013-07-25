$(function() {
	$('#datepicker')
		.Calendar({'weekStart': 7})
		.on('changeDay', function(event){
			load_day(event.year, event.month, event.day);
		});
	init_bar_tooltip();
});

function init_bar_tooltip() {
	$('div.progress div.bar').tooltip({
		placement: 'right',
		container: 'body'
	})
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
		$('#loading-spinner').fadeOut();
	});
}
