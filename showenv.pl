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
use warnings;

use Term::ANSIColor;
use Term::ReadKey;
use List::Util qw(min max);

BEGIN {
    our $VERSION = '1.05';
}

my ($wchar, $hchar, $wpixels, $hpixels) = GetTerminalSize();
my $MAX  = 0;
my $ul   = "\e[4m";
my $bold = "\e[1m";

foreach my $e (keys %ENV) {
    $MAX = max(length($e), $MAX);
}

print "\n", colored(['bright_yellow', 'on_blue'], "\e[2K  Environment Variables"), "\n";

foreach my $env (sort(keys %ENV)) {
    if ($env eq 'WHATISMYIP_INFO') {
        my @in     = split(/\n|;/, $ENV{$env});
        my $indent = $MAX + 4;
        my $ch     = $bold . colored(['black on_bright_black'], sprintf(" %${MAX}s ", $env)) . " = $ENV{$env}";
        print "$ch\n";
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
                my $le = 12 - length($f);
                $f = ' ' x $le . $f if ($le > 0);

                $l = colored(['green'],    uc($l))                                                                  if ($l =~ /^ok/i);
                $l = colored(['bold red'], 'U') . colored(['bold white'], 'S') . colored(['bold bright_blue'], 'A') if ($l =~ /^us/i);
                print colored(['bold cyan'], sprintf("%${indent}s", $f)) . " = $l\n";
            } else {
                print "$line\n";
            }
        } ## end foreach my $line (@in)
	} elsif ($env =~ /^(PATH|LS_COLORS)$/) {
		my @in     = split(/:/, $ENV{$env});
        my $indent = $MAX + 4;
        my $ch     = $bold . colored(['black on_bright_black'], sprintf(" %${MAX}s ", $env)) . " = $ENV{$env}";
        print "$ch\n";
		my $count = 0;
		my $max = ($wchar - 25) / 20;
		foreach my $line (@in) {
			if ($env eq 'PATH') {
				my $f  = ' ' x 25 . $line;
				print colored(['bold cyan'], $f), "\n";
			} else {
				if ($count == 0) {
					print colored(['bold cyan'], sprintf('%25s', $line));
					$count++;
				} else {
					print colored(['bold cyan'], sprintf('%20s', $line));
					$count++;
					if ($count > $max) {
						print "\n";
						$count = 0;
					}
				}
			}
		}
		print "\n" if ($env eq 'LS_COLORS' && $count);
    } else {
        print $bold, colored(['black on_bright_black'], sprintf(" %${MAX}s ", $env)) . ' = ' . colorize_values($env, $ENV{$env}) . "\n";
    }
} ## end foreach my $env (sort(keys ...))

print colored(['on_blue'], "\e[2K"), "\n";

exit(0);

sub colorize_values {
    my $env  = shift;
    my $orig = shift;
    my $new  = $orig;

    if ($orig =~ /(\d+\.\d+\.\d+\.\d+)/) {
        $new = colored(['bright_green'], $orig);
        $orig =~ s/$1/$new/g;
    }
    if ($orig =~ /(truecolor)/i) {
        $new = colored(['red'], 't') . colored(['green'], 'r') . colored(['yellow'], 'u') . colored(['cyan'], 'e') . colored(['bright_blue'], 'c') . colored(['magenta'], 'o') . colored(['bright_green'], 'l') . colored(['bright_blue'], 'o') . colored(['cyan'], 'r');
        $orig =~ s/$1/$new/g;
    }
    if ($orig =~ /(256color)/i) {
        $new = colored(['red'], '2') . colored(['green'], '5') . colored(['yellow'], '6') . colored(['cyan'], 'c') . colored(['bright_blue'], 'o') . colored(['magenta'], 'l') . colored(['bright_green'], 'o') . colored(['bright_blue'], 'r');
        $orig =~ s/$1/$orig/g;
    }
    if ($orig =~ /(ubuntu)/i) {
        $new = colored(['ansi202'], $1);
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
        $new = colored(['bright_green'], $1);
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
	if ($orig =~ /^(true)$/i) {
		$new = colored(['green'], $1);
		$orig =~ s/$1/$new/g;
	}
	if ($orig =~ /^(stderr)$/i) {
		$new = colored(['red'], $1);
		$orig =~ s/$1/$new/g;
	}
    return ($new);
} ## end sub colorize_values

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

=cut

