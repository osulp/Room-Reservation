$(function() {
	init_bar_tooltip();
});

function init_bar_tooltip() {
	$('div.progress div.bar').tooltip({
		placement: 'right',
		container: 'body'
	})
}