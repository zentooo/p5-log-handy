#!perl -w
use strict;
use Test::More;
use Test::Exception;

use Time::Piece ();
use File::Temp qw/tempfile tempdir/;

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
        autoflush => 1,
    };
    my $file = Log::Handy::Output::File->new(+{ opts => $opts });
    isa_ok( $file, "Log::Handy::Output::File" );

    for my $level (@Log::Handy::LEVELS) {
        my $time = Time::Piece::localtime();
        $file->log($level, "foo\n", $opts, $time);
    }

    while ( my $line = <$fh> ) {
        like ( $line, qr/^foo$/ );
    }
});

subtest("log with dirname", sub {
    my $tempdir = tempdir(CLEANUP => 1);
    note $tempdir;

    my $opts = +{
        min_level => "warn",
        max_level => "critical",
        mode => ">>",
        dirname => $tempdir,
        filename => "foo.log",
    };
    my $file = Log::Handy::Output::File->new(+{ opts => $opts });
    isa_ok( $file, "Log::Handy::Output::File" );

    my $time = Time::Piece::localtime();

    lives_ok {
        $file->log("warn", "foo\n", $opts, $time);
    } "we can emit logs with dirname";
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
    my $file = Log::Handy::Output::File->new(+{ opts => $opts });
    isa_ok( $file, "Log::Handy::Output::File" );

    for my $level (@Log::Handy::LEVELS) {
        my $time = Time::Piece::localtime();
        lives_ok {
            $file->log($level, "foo\n", $opts, $time);
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

    my $file = Log::Handy::Output::File->new(+{ opts => $opts1 });
    isa_ok( $file, "Log::Handy::Output::File" );

    my $time = Time::Piece::localtime();

    lives_ok {
        $file->log("warn", "foo\n", $opts1, $time);
    } "we can omit mode because it has default value = '>>'";

    dies_ok {
        $file->log("warn", "foo\n", $opts2, $time);
    } "we can not omit filename because it does not have default value";

    dies_ok {
        $file->log("warn", "foo\n", $opts3, $time);
    } "we can not pass string as level_dispatch";

    dies_ok {
        $file->log("warn", "foo\n", $opts4, $time);
    } "we can not pass string as close_after_write";
});

done_testing;
