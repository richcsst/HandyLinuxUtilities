#!/usr/bin/env perl

use strict;
use LWP::Simple;
use JSON::Parse 'parse_json';

# Check if any environment variables starting with WHATISMYIP_ already exist
my @existing_vars = grep { /^WHATISMYIP_/ } keys %ENV;

if (@existing_vars) {
    die "WHATISMYIP variables already exist. Skipping API call.\n";
}

# wimip.pl [key]
if (scalar(@ARGV)) {
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
    }
} else {
    die "Missing key\n";
}

exit(0);
