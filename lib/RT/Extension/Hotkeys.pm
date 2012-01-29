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
                'v'       => { body => q!hotkeys.version()!, doc => 'version', },
                'shift+/' => { body => q!hotkeys.help()!,    doc => 'help', },
                'g'       => {
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
                    'd' => {
                        body => q!hotkeys.openLink("/Dashboards/index.html")!,
                        doc  => 'dashboards',
                    },
                    'h' => { body => q!hotkeys.openLink("/")!, doc => 'home', },
                    'l' => {
                        body => q!hotkeys.openLink("/NoAuth/Logout.html")!,
                        doc  => 'logout',
                    },
                    'n' => {
                        body => q!hotkeys.submit('#CreateTicketInQueue')!,
                        doc  => 'create ticket in default queue',
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
                    'r' => {
                        body => q!location.reload()!,
                        doc  => 'reload',
                    },
                    's' => {
                        body => q!hotkeys.openLink('/Search/Build.html')!,
                        doc  => 'search builder',
                    },
                    't' => { body => q!hotkeys.ticket()!, doc => 'goto ticket' },
                    'u' => {
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
                        'u' => {
                            body => q!hotkeys.openLink("/Tools")!,
                            doc  => 'tools',
                        },
                    },
                },
            },
            '/Ticket/' => {
                a => {
                    'c' => {
                        body =>
                          q!hotkeys.open('#page-menu a[href*="Action=Comment"]')!,
                        doc => 'comment',
                    },
                    'shift+c' => {
                        body =>
    q!hotkeys.open('#page-menu a[href*="Action=Comment"]:last')!,
                        doc => 'comment based on the last message',
                    },
                    'e' => {
                        body =>
    q!hotkeys.open('#page-menu a[href*="/Articles/Article/ExtractIntoClass.html"]')!,
                        doc => 'forward',
                    },
                    'f' => {
                        body =>
    q!hotkeys.open('#page-menu a[href*="/Ticket/Forward.html"]')!,
                        doc => 'forward',
                    },
                    'shift+f' => {
                        body =>
                          q!hotkeys.open('a[href*="/Ticket/Forward.html"]:last')!,
                        doc => 'forward the last message',
                    },
                    'j' => {
                        body =>
    q!hotkeys.open('#page-menu a[href*="DefaultStatus=rejected"]')!,
                        doc => 'reject',
                    },
                    'l' => {
                        body =>
    q!hotkeys.open('#page-menu a[href*="DefaultStatus=resolved"]')!,
                        doc => 'resolve',
                    },
                    'o' => {
                        body =>
    q!hotkeys.open('#page-menu a[href*="DefaultStatus=open"]')!,
                        doc => 'open',
                    },
                    's' => {
                        body =>
    q!hotkeys.open('#page-menu a[href*="DefaultStatus=stalled"]')!,
                        doc => 'stall',
                    },
                    'r' => {
                        body =>
                          q!hotkeys.open('#page-menu a[href*="Action=Respond"]')!,
                        doc => 'reply',
                    },
                    'shift+r' => {
                        body => q!hotkeys.open('a[href*="Action=Respond"]:last')!,
                        doc  => 'reply based on the last message',
                    },
                    't' => {
                        body =>
                          q!hotkeys.open('#page-menu a[href*="Action=take"]')!,
                        doc => 'open',
                    },
                },
                'b' => {
                    body =>
    q!hotkeys.click('#page-menu a[href*="/Helpers/Toggle/TicketBookmark"]')!,
                    doc => 'toggle bookmark',
                },
                'd' => {
                    body =>
                      q!hotkeys.open('#page-menu a[href*="/Ticket/Display.html"]')!,
                    doc => 'display',
                },
                'h' => {
                    body =>
                      q!hotkeys.open('#page-menu a[href*="/Ticket/History.html"]')!,
                    doc => 'history',
                },
                'm' => {
                    'a' => {
                        body =>
    q!hotkeys.open('#page-menu a[href*="/Ticket/ModifyAll.html"]')!,
                        doc => 'modify all',
                    },
                    'b' => {
                        body =>
    q!hotkeys.open('#page-menu a[href*="/Ticket/Modify.html"]')!,
                        doc => 'modify basics',
                    },
                    'd' => {
                        body =>
    q!hotkeys.open('#page-menu a[href*="/Ticket/ModifyDates.html"]')!,
                        doc => 'modify dates',
                    },
                    'l' => {
                        body =>
    q!hotkeys.open('#page-menu a[href*="/Ticket/ModifyLinks.html"]')!,
                        doc => 'modify links',
                    },
                    'p' => {
                        body =>
    q!hotkeys.open('#page-menu a[href*="/Ticket/ModifyPeople.html"]')!,
                        doc => 'modify people',
                    },
                },
                'r' => {
                    body =>
    q!hotkeys.open('#page-menu a[href*="/Ticket/Reminders.html"]')!,
                    doc => 'reminders',
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


