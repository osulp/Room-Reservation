$(function() {
	$( "#searchTabs" ).tabs();

});
function osuSearch(){
	window.location = 'https://osulibrary.oregonstate.edu/search/site/' + $('#wsearch').val();
}
