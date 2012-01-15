use warnings;
use strict;

package RT::Extension::Hotkeys;

our $VERSION = "0.01";

use RT;

RT->AddJavaScript(
    qw/
      jquery.hotkeys.js
      jquery.simplemodal.js
      hotkeys.js
      /
);

RT->AddStyleSheets('hotkeys.css');

use RT::Config;

$RT::Config::META{DisableHotkeys} = {
    Section         => 'General',
    Overridable     => 1,
    SortOrder       => 10,
    Widget          => '/Widgets/Form/Boolean',
    WidgetArguments => {
        Description => 'Disable hotkeys'    # loc
    },
};

sub ConfAsJS {
    my $conf = shift;
    return {} unless $conf && keys %$conf;

    my $str = '{';
    for my $key ( keys %$conf ) {
        $key =~ s!'!\\'!g;
        if ( ref $conf->{$key} ) {
            if ( exists $conf->{$key}{body} ) {
                $str .= "'$key': function() { $conf->{$key}{body} },\n";
            }
            else {
                $str .= "'$key': " . ConfAsJS( $conf->{$key} ) . ",\n";
            }
        }
        else {
            $str .= "'$key': function() { $conf->{$key} },\n";
        }
    }
    $str =~ s!,\n$!\}!;    # \} is to make vim happy
    return $str;
}

sub Help {
    my $conf = shift;
    my $level = shift || 0;
    return '' unless $conf && keys %$conf;

    my $str;

    if ( $level == 0 ) {
        for my $item ( sort { $a eq 'global' ? -1 : $a <=> $b }keys %$conf ) {
            $str .= "===== $item =====\\n\\n";
            $str .= Help( $conf->{$item}, $level + 1 );
            $str .= "\\n";
        }
    }
    else {

        for my $key ( sort keys %$conf ) {
            if ( ref $conf->{$key} ) {
                if ( !ref $conf->{$key} || exists $conf->{$key}{body} ) {
                    my $doc = $conf->{$key}{doc} || $conf->{$key}{body};
                    $str .= '  ' x ($level-1) . "$key -> $doc\\n";
                }
                else {
                    $str .=
                        '  ' x ($level-1)
                      . "$key ->\\n"
                      . Help( $conf->{$key}, $level + 1 );
                }
            }
            else {
                $str .= '    ' x ($level-1) . "$key -> $conf->{$key}\\n";
            }
        }
    }
    return $str;
}

1;
__END__

=head1 NAME

RT::Extension::Hotkeys - hotkeys for rt web interface

=head1 VERSION

Version 0.01

=head1 INSTALLATION

This extension only works with RT 4 or later.

To install this module, run the following commands:

    perl Makefile.PL
    make
    make install

add RT::Extension::Hotkeys to @Plugins in RT's etc/RT_SiteConfig.pm:

    Set( @Plugins, qw(... RT::Extension::Hotkeys) );
    Set( $DisableHotkeys, 1 ); # disable it by default

customize %Hotkeys to meet your needs:

    Set(
        %Hotkeys,
        (
            global => {
                'v' => { body => q!hotkeys.version()!, doc => 'version', },
                'shift+/' => { body => q!hotkeys.help()!, doc => 'help', },
                't' => { body => q!hotkeys.ticket()!, doc => 'goto ticket' },
                'g' => {
                    'a' => {
                        body => q!hotkeys.openLink("/Approvals")!,
                        doc  => 'approvals',
                    },
                    'c' => {
                        'c' => {
                            body => q!hotkeys.openLink("/Admin/")!,
                            doc  => 'admin',
                        },
                        'g' => {
                            body => q!hotkeys.openLink("/Admin/Global.html")!,
                            doc  => 'admin global',
                        },
                    },
                    'h' => { body => q!hotkeys.openLink("/")!, doc => 'home', },
                    'l' => {
                        body => q!hotkeys.openLink("/NoAuth/Logout.html")!,
                        doc  => 'logout',
                    },
                    'p' => {
                        'h' => {
                            body => q!hotkeys.openLink("/Prefs/Hotkeys.html")!,
                            doc  => 'customize hotkeys',
                        },
                        'p' => {
                            body => q!hotkeys.openLink("/Prefs/Other.html")!,
                            doc  => 'customize options',
                        },
                    },
                    's' => {
                        body => q!hotkeys.openLink('/Search/Build.html')!,
                        doc  => 'search builder',
                    },
                    't' => {
                        'd' => {
                            body => q!hotkeys.openLink("/Tools/MyDay.html")!,
                            doc  => 'my day',
                        },
                        'o' => {
                            body => q!hotkeys.openLink("/Tools/Offline.html")!,
                            doc  => 'offline',
                        },
                        'm' => {
                            body => q!hotkeys.openLink("/Tools/MyReminders")!,
                            doc  => 'my reminders',
                        },
                        't' => {
                            body => q!hotkeys.openLink("/Tools")!,
                            doc  => 'tools',
                        },
                    },
                },
                'n' => {
                    body => q!hotkeys.submit('#CreateTicketInQueue')!,
                    doc  => 'create ticket in default queue',
                },

            },
            '/Ticket/' => {
                'b' => {
                    body =>
q!hotkeys.click('a[href*="/Helpers/Toggle/TicketBookmark"]')!,
                    doc => 'toggle bookmark',
                },
                'c' => {
                    body => q!hotkeys.open('a[href*="Action=Comment"]')!,
                    doc  => 'comment',
                },
                'shift+c' => {
                    body => q!hotkeys.open('a[href*="Action=Comment"]:last')!,
                    doc  => 'comment',
                },
                'r' => {
                    body => q!hotkeys.open('a[href*="Action=Respond"]')!,
                    doc  => 'reply',
                },
                'shift+r' => {
                    body => q!hotkeys.open('a[href*="Action=Respond"]:last')!,
                    doc  => 'reply',
                },
            },
        )
    );

=head1 AUTHOR

sunnavy, <sunnavy at bestpractical.com>


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Best Practical Solutions, LLC

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


