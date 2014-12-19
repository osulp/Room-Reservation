(function ($) {

    $('#quicktabs-osu_library_search').tabs({
        activate: function( event, ui ) {
            // Set clicked tab to active.
            ui.oldTab.removeClass('active');
            ui.newTab.addClass('active');
        }
    });

    searchSubmit = function(event, url) {
        // Stitch together the search string
        event.preventDefault();
        var extra = '';
        if ($(this).closest('form[id]').attr('id') == 'osul-search-library-form') {
            $('input[name=query]').val('any,contains,' + $('input[name=query_temp]').val());
        } else {
            extra = '&query=any,contains,' + $('input[name=query_temp_reserve]').val();
        }
        window.location = "http://search.library.oregonstate.edu/primo_library/libweb/action/dlSearch.do?" + $(this).serialize() + extra;
    }

    $('#osul-search-library-form').submit(searchSubmit);
    $('#osul-search-reserves-form').submit(searchSubmit);

})(jQuery);