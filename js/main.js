/*
 * ## Aurelius ##
 *
 * This function loads the random quote data from a JSON file
 * and renders it on the page. Since Chrome extensions handle
 * URLs in a special way, I have to first check if this is the
 * Chrome extension before building the URL for the JSON call.
 *
 */
function Aurelius() {
    var url = './data/marcus.json';

    /* JSON for Marcus Aurelius quotes */
    $.getJSON(url, function(data) {
        // Select a random entry
        var entry   = data[Math.floor(Math.random()*data.length)];
        var chapter = entry['chapter'];
        var section = entry['section'];
        var cite    = 'Marcus Aurelius, <i>Meditations</i>.<br/>Chapter ' + chapter + ', section ' + section + '.';
        $('#marcus header cite').html(cite);
        for ( var key in entry['quote'] ) {
            var obj = entry['quote'][key];
            $('#marcus').append('<p>' + obj + '</p>')
        };
    });
}


$(document).ready(function() {

    Aurelius();

    $('.site').delay(250).fadeIn(1000); // And Ben said, "Let there be webpage!"

});
