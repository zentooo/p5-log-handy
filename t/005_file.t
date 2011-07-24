#!perl -w
use strict;
use Test::More;
use Test::Exception;

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

subtest("log with file format", sub {
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
        lives_ok {
            $screen->log($level, "foo\n", $opts, $time);
        } "we can emit logs with many names";
    }
});

subtest("defalut parameters ant nots", sub {
    my ($fh, $tempfile) = tempfile();

    my $opts1 = +{
        min_level => "warn",
        max_level => "critical",
        filename => $tempfile,
    };

    my $opts2 = +{
        min_level => "warn",
        max_level => "critical",
    };

    my $opts3 = +{
        min_level => "warn",
        max_level => "critical",
        level_dispatch => "hoge",
        close_after_write => 1,
    };

    my $opts4 = +{
        min_level => "warn",
        max_level => "critical",
        level_dispatch => 1,
        close_after_write => "hoge",
    };

    my $screen = Log::Handy::Output::File->new(+{ opts => $opts1 });
    isa_ok( $screen, "Log::Handy::Output::File" );

    my $time = Time::Piece::localtime();

    lives_ok {
        $screen->log("warn", "foo\n", $opts1, $time);
    } "we can omit mode because it has default value = '>>'";

    dies_ok {
        $screen->log("warn", "foo\n", $opts2, $time);
    } "we can not omit filename because it does not have default value";

    dies_ok {
        $screen->log("warn", "foo\n", $opts3, $time);
    } "we can not pass string as level_dispatch";

    dies_ok {
        $screen->log("warn", "foo\n", $opts4, $time);
    } "we can not pass string as close_after_write";
});

done_testing;
