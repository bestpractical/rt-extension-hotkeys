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

sub Convert {
    my $conf = shift;
    return {} unless $conf;

    my $str  = '{';
    for my $key ( keys %$conf ) {
        $key =~ s!'!\\'!g;
        if ( ref $conf->{$key} ) {
            if ( exists $conf->{$key}{body} ) {
                $str .= "'$key': function() { $conf->{$key}{body} },\n";
            }
            else {
                $str .= "'$key': " . Convert( $conf->{$key} ) . ",\n";
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
    return '' unless $conf;

    my $str;

    for my $key ( sort keys %$conf ) {
        if ( ref $conf->{$key} ) {
            if ( !ref $conf->{$key} || exists $conf->{$key}{body} ) {
                my $doc = $conf->{$key}{doc} || $conf->{$key}{body};
                $str .= '    ' x $level . "$key -> $doc\\n";
            }
            else {
                $str .=
                    '    ' x $level
                  . "$key ->\\n"
                  . Help( $conf->{$key}, $level + 1 );
            }
        }
        else {
            $str .= '    ' x $level . "$key -> $conf->{$key}\\n";
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

customize %Hotkeys to meet your needs:

    Set(
        %Hotkeys,
        (
            'v'       => { body => q!version()!, doc => 'version', },
            'shift+/' => { body => q!help()!,    doc => 'help', },
            'shift+/' => { body => q!help()!,    doc => 'help', },
            'h'       => { body => q!open('/')!, doc => 'home', },
            '/'       => {
                body => q!open('/Search/Build.html')!,
                doc  => 'search builder',
            },
            't' => { body => q!ticket()!, doc => 'go to ticket' },
            'b' => {
                body =>
                  q!click('a[href*="/Helpers/Toggle/TicketBookmark"]:first')!,
                doc => 'toggle bookmark',
            },
            'c' => {
                body => q!open('a[href*="Action=Comment"]:first')!,
                doc  => 'comment',
            },
            'r' => {
                body => q!open('a[href*="Action=Respond"]:first')!,
                doc  => 'reply',
            },
            'g' => {
                'a' => { body => q!open("/Admin")!, doc => 'admin', },
                't' => { body => q!open("/Tools")!, doc => 'tools', },
            },
            'n' => {
                body => q!submit('#CreateTicketInQueue')!,
                doc  => 'create ticket',
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


