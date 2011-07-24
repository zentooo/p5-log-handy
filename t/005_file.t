#!perl -w
use strict;
use Test::More;

use Time::Piece ();
use File::Temp qw/tempfile/;

use Log::Handy;

BEGIN {
    use_ok 'Log::Handy::Output::File';
}

subtest("new and log", sub {
    my ($fh, $tempfile) = tempfile();
    note $tempfile;

    my $opts = +{
        min_level => "warn",
        max_level => "critical",
        mode => ">>",
        filename => $tempfile,
    };
    my $screen = Log::Handy::Output::File->new(+{ opts => $opts });
    isa_ok( $screen, "Log::Handy::Output::File" );

    for my $level (@Log::Handy::LEVELS) {
        my $time = Time::Piece::localtime();
        $screen->log($level, "foo\n", $opts, $time);
    }

    while ( my $line = <$fh> ) {
        like ( $line, qr/^foo$/ );
    }
});

subtest("new and log", sub {
    my ($fh, $tempfile) = tempfile();
    note $tempfile;

    my $opts = +{
        min_level => "warn",
        max_level => "critical",
        filename => $tempfile . '_%T{%Y%m%d}_%l.log',
        mode => ">>",
        level_dispatch => 1,
    };
    my $screen = Log::Handy::Output::File->new(+{ opts => $opts });
    isa_ok( $screen, "Log::Handy::Output::File" );

    for my $level (@Log::Handy::LEVELS) {
        my $time = Time::Piece::localtime();
        $screen->log($level, "foo\n", $opts, $time);
    }

    ok(1);
});

done_testing;
