#!/usr/bin/env perl

use strict;

use Text::Markdown;

if (scalar(@ARGV)) {
	open(my $FILE, '<', $ARGV[0]);
	my $text = '';
	while(my $line = <$FILE>) {
		$text .= $line;
	}
	close($FILE);
	my $m = Text::Markdown->new;
	my $html = $m->markdown($text);

	open(my $OUT, '|-', 'lynx -stdin');
	print $OUT $html;
	close($OUT);
}

exit(0);
