(function ($) {

    $('#quicktabs-osu_library_search').tabs({
        activate: function( event, ui ) {
            // Set clicked tab to active.
            ui.oldTab.removeClass('active');
            ui.newTab.addClass('active');
        }
    });

    searchSubmit = function (event, url) {
        // Stitch together the search string
        var query = '';
        event.preventDefault();
        if ($(this).closest('form[id]').attr('id') == 'osul-search-library-form') {
            query = $('input[name=query_temp]').val().replace(/,/g, ' ');
        } else {
            query = $('input[name=query_temp_reserve]').val().replace(/,/g, ' ');
        }
        $('input[name=query]').val('any,contains,' + query)
        window.location = "http://search.library.oregonstate.edu/primo_library/libweb/action/dlSearch.do?" + $(this).serialize();
    };

    $('#osul-search-library-form').submit(searchSubmit);
    $('#osul-search-reserves-form').submit(searchSubmit);

})(jQuery);