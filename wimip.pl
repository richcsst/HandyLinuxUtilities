#!/usr/bin/env perl

use strict;
use LWP::Simple;

# wimip.pl [key]
if (scalar(@ARGV)) {
    if (exists($ENV{'WHATISMYIP_INFO'}) && defined($ENV{'WHATISMYIP_INFO'}) && $ENV{'WHATISMYIP_INFO'} ne '') {
        print $ENV{'WHATISMYIP_INFO'};
    } else {
        my $wimip_url = 'https://api.whatismyip.com/ip.php?key=' . $ARGV[0];
        my $ip;
        unless (defined($ip = get($wimip_url))) {
            die "$wimip_url not responding as expected\n";
        }
        chomp($ip);
        my $wimip_info_url = 'https://api.whatismyip.com/ip-address-lookup.php?key=' . $ARGV[0] . '&input=' . $ip;
        my $meta;
        unless(defined($meta = get($wimip_info_url))) {
            die "$wimip_info_url not responding as expected\n";
        }
        my @info = split(/\n/, $meta);
        my $processed = join(';', @info);
        $processed =~ s/\s*\;\s*/;/gs;
        print $processed;
    }
} else {
    die "Missing key\n";
}

exit(0);
