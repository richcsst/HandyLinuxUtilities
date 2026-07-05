#!/usr/bin/env perl

use strict;
use LWP::Simple;
use JSON::Parse 'parse_json';
# wimip.pl [key]
if (scalar(@ARGV)) {
    if (exists($ENV{'WHATISMYIP_INFO'}) && defined($ENV{'WHATISMYIP_INFO'}) && $ENV{'WHATISMYIP_INFO'} ne '') {
        print $ENV{'WHATISMYIP_INFO'};
    } else {
	my $key = $ARGV[0];
        my $wimip_url = 'https://wimi-api.whatismyip.com/ip?key=' . $key;
        my $json_ip;
        unless (defined($json_ip = get($wimip_url))) {
            die "$wimip_url not responding as expected\n";
        }
        chomp($json_ip);
	my $ip = parse_json($json_ip);
        my $wimip_info_url = 'https://wimi-api.whatismyip.com/ip-address-lookup/' . $ip->{'ip'} . "?key=$key";
        my $meta;
        unless(defined($meta = get($wimip_info_url))) {
            die "$wimip_info_url not responding as expected\n";
        }
	my $ip_info = parse_json($meta);
	foreach my $name (keys %{$ip_info}) {
	    print "export WHATISMYIP_" . uc($name) . '="' . $ip_info->{$name} . '"' . "\n";
#	    system("export WHATISMYIP_" . uc($name) . '=' . $ip_info->{$name});
	}
    }
} else {
    die "Missing key\n";
}

exit(0);
