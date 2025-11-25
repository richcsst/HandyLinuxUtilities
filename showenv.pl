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
use List::Util qw(min max);

BEGIN {
	our $VERSION = '1.04';
}

my $MAX = 0;

foreach my $e (keys %ENV) {
    $MAX = max(length($e), $MAX);
}

print "\n", colored(['bright_white','on_blue'], "\e[2K  Environment Variables"), "\n";

foreach my $env (sort(keys %ENV)) {
    if ($ENV{$env} =~ /\n/) {
        my @in     = split(/\n/, $ENV{$env});
        my $indent = $MAX + 4;
		my $new = sprintf("%${MAX}s = ---", $env), "\n";
		my $ch  = colored(['bright_white'],'WHATISMYIP_INFO');
        $new =~ s/WHATISMYIP_INFO/$ch/;
		print "$new\n";
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
                $l = colored(['bold red'], 'U') . colored(['bold white'], 'S') . colored(['bold bright_blue'], 'A') if ($l =~ /^us/i);
                print colored(['bold cyan'], sprintf("%${indent}s", $f)) . " = $l\n";
            } else {
                print "$line\n";
            }
        } ## end foreach my $line (@in)
    } else {
		print colored(['bold white'], sprintf("%${MAX}s", $env)) . ' = ' . colorize_values($env,$ENV{$env}) . "\n";
    }
} ## end foreach my $env (sort(keys ...))

print colored(['on_blue'],"\e[2K"), "\n";;

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
	return($new);
}

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

