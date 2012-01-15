hotkeys = {
    show: function( string ) {
        jQuery('<pre>' + string + '</pre>').modal();
    },
    notFound: function( string ) {
        jQuery('<pre>' + string + ' is not found</pre>').modal();
    },
    submit: function( e ) {
        var obj = jQuery(document).find(e).filter(':first');
        if ( obj.size() ) {
            obj.submit();
        }
        else {
            hotkeys.notFound( e );
        }
    },
    click: function( e ) {
        var obj = jQuery(document).find(e).filter(':first');
        if ( obj.size() ) {
            obj.click();
        }
        else {
            hotkeys.notFound( e );
        }
    },
    openLink: function( e ) {
        window.location = e;
    },
    open: function( e ) {
        var obj = jQuery(document).find(e).filter(':first');
        if ( obj.size() ) {
            window.location = jQuery(e).attr('href');
        }
        else {
            hotkeys.notFound( e );
        }
    },
    ticket: function( number ) {
        if ( !number ) {
            number = prompt("<% loc('Goto Ticket') %>", "");
        }

        if (number){
            window.location = '<% RT->Config->Get('WebPath') %>/Ticket/Display.html?id=' + number;
        }
    },
    bind: function( conf, global ) {
        jQuery(document).unbind('keydown.hotkeys');
        jQuery(document).bind('keydown.hotkeys', 'esc', function() { hotkeys.bind(global || conf) } );

        for ( key in conf ) {
            if ( typeof( conf[key] ) == 'function' ) {
                (function(key) {
                    jQuery(document).bind('keydown.hotkeys', key,
                        function() {
                            conf[key]();
                            if ( global ) {
                                hotkeys.bind(global);
                            }
                        }
                    );
                })(key);
            }
            else {
                (function(key) {
                    jQuery(document).bind('keydown.hotkeys', key, function() { hotkeys.bind( conf[key], global ) } );
                })(key);
            }
        }
    }
};

