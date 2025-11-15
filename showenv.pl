#!/usr/bin/env perl

##############################################################################
#                         Show Environmt Variables                           #
# -------------------------------------------------------------------------- #
#                               showenv.pl                                   #
#                      Copyright 2025 Richard Kelsch                         #
#                           All Rights Reserved                              #
#               Licensed under the Perl Artistic License 2.0                 #
##############################################################################

use strict;

use Term::ANSIColor;
use List::Util qw(min max);

BEGIN {
	our $VERSION = '1.03';
}

my $MAX = 0;

foreach my $e (keys %ENV) {
    $MAX = max(length($e), $MAX);
}

print "\n", colored(['bright_white','on_blue'], '################'), colored(['bright_yellow'], ' Environment Variables '), colored(['bright_white','on_blue'], '###################'), "\n\n";

foreach my $env (sort(keys %ENV)) {
    if ($ENV{$env} =~ /\n/g) {
        my @in     = split(/\n/, $ENV{$env});
        my $indent = $MAX + 4;
        print sprintf("%${MAX}s = ---", $env), "\n";
        foreach my $line (@in) {
            if ($line =~ /\:/) {
                my ($f, $l) = $line =~ /^(.*?):(.*)/;
                chomp($l);
                chomp($f);
                $f = uc($f);
                if ($f eq 'IP') {
                    $l = colored(['bright_green'], $l);
                    $f = 'IP ADDRESS';
                } elsif ($f eq 'ISP') {
					$l = colored(['bright_white'], $l);
				}
                my $le = 11 - length($f);
                $f .= ' ' x $le;

                $l = colored(['green'],    uc($l))                                                           if ($l =~ /^ok/i);
                $l = colored(['bold red'], 'United ') . colored(['bold white'], 'States') . ' of ' . colored(['bold bright_blue'], 'America') if ($l =~ /^us/i);
				$l = colored(['bold red'],'Ca') . colored(['bold white'], 'na') . colored(['bold red'], 'da') if ($l =~ /^ca/i);
				$l = colored(['bold red'],'Me') . colored(['bold white'], 'xi') . colored(['bold green'], 'co') if ($l =~ /^me/i);
				$l = colored(['bold red'],'The ') . colored(['bold white'], 'United ') . colored(['bold bright_blue'], 'Kingdom') if ($l =~ /^uk/i);
                print colored(['bold white'], sprintf("%${indent}s", $f)) . " = $l\n";
            } else {
                print "$line\n";
            }
        } ## end foreach my $line (@in)
    } elsif ($env eq 'SSH_CLIENT') {
        my ($ip, $p1, $p2) = split(/ /, $ENV{$env});
        print colored(['bold white'], sprintf("%${MAX}s", $env)), ' = ', colored(['bright_green'], $ip), ' ', colored(['cyan'], $p1), ' ', colored(['yellow'], $p2), "\n";
    } elsif ($env eq 'SSH_CONNECTION') {
        my ($ip1, $p1, $ip2, $p2) = split(/ /, $ENV{$env});
        print colored(['bold white'], sprintf("%${MAX}s", $env)), ' = ', colored(['bright_green'], $ip1), ' ', colored(['cyan'], $p1), ' ', colored(['bright_green'], $ip2), ' ', colored(['yellow'], $p2), "\n";
	} elsif ($env eq 'COLORTERM' && $ENV{'COLORTERM'} eq 'truecolor') {
        my $colorized = colored(['red'], 't') . colored(['green'], 'r') . colored(['yellow'], 'u') . colored(['cyan'], 'e') . colored(['bright_blue'], 'c') . colored(['magenta'], 'o') . colored(['bright_green'], 'l') . colored(['bright_blue'], 'o') . colored(['cyan'], 'r');
        my $line      = $ENV{$env};
        $line =~ s/truecolor/$colorized/;
        print colored(['bold white'], sprintf("%${MAX}s", $env)), ' = ', $line, "\n";
    } elsif ($env eq 'TERM') {
        my $colorized = colored(['red'], '2') . colored(['green'], '5') . colored(['yellow'], '6') . colored(['cyan'], 'c') . colored(['bright_blue'], 'o') . colored(['magenta'], 'l') . colored(['bright_green'], 'o') . colored(['bright_blue'], 'r');
        my $line      = $ENV{$env};
        $line =~ s/256color/$colorized/;
        print colored(['bold white'], sprintf("%${MAX}s", $env)), ' = ', $line, "\n";
    } elsif ($env eq 'WHATISMYIP') {
        print colored(['bold white'], sprintf("%${MAX}s", $env)), ' = ', colored(['bright_green'], $ENV{$env}), "\n";
    } else {
		my $orig = $ENV{$env};
		my $new;
		if ($orig =~ /(ubuntu)/i) {
			$new = "\e[202m" . $1 . "\e[0m";
			$orig =~ s/$1/$new/g;
		}
		if ($orig =~ /(redhat)/i) {
			$new = colored(['bright_red'], $1);
			$orig =~ s/$1/$new/g;
		}
		if ($orig =~ /(fedora)/i) {
			$new = colored(['bright_cyan'], $1);
			$orig =~ s/$1/$new/g;
		}
		if ($orig =~ /(mint)/i) {
			$new = colored(['bright_green'],$1);
			$orig =~ s/$1/$new/g;
		}
		if ($orig =~ /(zorin)/i) {
			$new = colored(['bright_white'], $1);
			$orig =~ s/$1/$new/g;
		}
		if ($orig =~ /(wayland)/i) {
			$new = colored(['bright_yellow'], $1);
			$orig =~ s/$1/$new/g;
		}
		print colored(['bold white'], sprintf("%${MAX}s", $env)) . ' = ' . $orig . "\n";
    }
} ## end foreach my $env (sort(keys ...))

print "\n";

exit(0);

__END__

=pod

=encoding utf8

=head1 NAME

Show Environment Variables

=head1 SYNOPSIS

showenv.pl

=head1 DESCRIPTION

Returns the list of environment variables in a friendly and easy to read format.

=head1 AUTHOR

Richard Kelsch <rich@rk-internet.com>

=head1 COPYRIGHT

Copyright © 2025 Richard Kelsch
All Rights Reserved

=head1 LICENSE

Perl Artistic License 2.0

L<https://perlfoundation.org/artistic-license-20.html>

=head1 B<TOOTING MY OWN HORN>

Perl modules available on github - L<https://github.com/richcsst>

And available on CPAN:

 *  BBS::Universal
 *  Debug::Easy
 *  Graphics::Framebuffer
 *  Term::ANSIEncode

Also working on:

 *  BBS::Universal - A Perl based Internet BBS server

=cut
