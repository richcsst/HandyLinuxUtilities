#!/usr/bin/env perl

# Written by Richard Kelsch
# Copyright 2023-2025 Richard Kelsch
# Freely usable under the Perl Artistic License

use strict;

BEGIN {
    our $VERSION = '2.00';
}

use Sys::Info;
use Sys::Info::Constants qw( :device_cpu );

my $info = Sys::Info->new;
my $cpu  = $info->device('CPU');


if (defined($ARGV[0])) {
    if (my $httpd = $info->httpd) {
        print "HTTP Server is $httpd\n";
    }
    my $os = $info->os;
    printf("\n OS:  %s\n",$os->name(long => 1));
    printf("CPU:  %s\n\n",scalar($cpu->identify));
} else {
    print $cpu->count, "\n";
}

exit(0);

=pod

=encoding utf8

=head1 NAME

Get CPU Information

=head1 SYNOPSIS

    cpu_cores.pl

=head1 DESCRIPTION

=over 4

=item B<Get Full CPU Information>

    cpu_cores.pl full

=item B<Get Core Count>

Handy mode for .bashrc files where setting environment variables using core count can be set dunamically

    cpu_cors.pl

=back

=head1 AUTHOR

Richard Kelsch <rich@rk-internet.com>

=head1 COPYRIGHT

Copyright (c) 2025 Richard Kelsch
All Rights Reserved
Perl Artistic License

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it under the terms of the the Artistic License (2.0). You may obtain a copy of the full license at:

L<https://perlfoundation.org/artistic-license-20.html>

=cut
