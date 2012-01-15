(function(jQuery){
    function help () {
        var string =
            'RT::Extension::Hotkeys version <% $RT::Extension::Hotkeys::VERSION %>\n\n' +
            '<% $help |n%>';
        jQuery('<pre>' + string + '</pre>').modal();
    }

    function version () {
        jQuery('<pre>' + 'RT::Extension::Hotkeys version <% $RT::Extension::Hotkeys::VERSION %></pre>' ).modal();
    }

    function home(){
        window.location = '<% $web_path %>/';
    }

    function notFound( string ) {
        jQuery('<pre>' + string + ' is not found</pre>').modal();
    }

    function submit( e ) {
        var obj = jQuery(document).find(e).filter(':first');
        if ( obj.size() ) {
            obj.submit();
        }
        else {
            notFound( e );
        }
    }

    function click( e ) {
        var obj = jQuery(document).find(e).filter(':first');
        if ( obj.size() ) {
            obj.click();
        }
        else {
            notFound( e );
        }
    }

    function openLink( e ) {
        if ( e.match(/^\//) ) {
            window.location = '<% $web_path %>' + e;
        }
        else {
            window.location = e;
        }
    }

    function open( e ) {
        var obj = jQuery(document).find(e).filter(':first');
        if ( obj.size() ) {
            window.location = jQuery(e).filter(':first').attr('href');
        }
        else {
            notFound( e );
        }
    }

    function ticket() {
        var number = prompt("<% loc('Goto Ticket') %>", "");
        if (number){
            window.location = '<% $web_path %>/Ticket/Display.html?id=' + number;
        }
    }

    var hotkeys = <% RT::Extension::Hotkeys::Convert( $conf ) |n %>;

    function bind( conf, restore ) {
        jQuery(document).unbind('keydown.hotkeys');
        jQuery(document).bind('keydown.hotkeys', 'esc', function() { bind(hotkeys) } );

        for ( key in conf ) {
            if ( typeof( conf[key] ) == 'function' ) {
                (function(key) {
                    jQuery(document).bind('keydown.hotkeys', key,
                        function() {
                            conf[key]();
                            if ( restore ) {
                                bind(hotkeys);
                            }
                        }
                    );
                })(key);
            }
            else {
                (function(key) {
                    jQuery(document).bind('keydown.hotkeys', key, function() { bind( conf[key], 1 ) } );
                })(key);
            }
        }
    }

    jQuery( function() {
        bind( hotkeys );
    });
})(jQuery);

<%INIT>
my $web_path = RT->Config->Get('WebPath');
my $conf = RT->Config->Get( 'Hotkeys', $session{CurrentUser} );
my $help = RT::Extension::Hotkeys::Help( $conf );
$help =~ s!'!\\'!g;
</%INIT>
