#!perl -w
use strict;
use Test::More;
use Test::Output;

use File::Temp qw/tempfile/;

use Log::Handy;


subtest("new", sub {
    my $log = Log::Handy->new(+{});
    isa_ok( $log, "Log::Handy" );

    for my $level (@Log::Handy::LEVELS) {
        can_ok( $log, $level );
    }
});

subtest("new with outputs", sub {
    my $log = Log::Handy->new(
        outputs => +{
            screen => +{
                log_to => "STDOUT",
                min_level => "warn",
                max_level => "critical",
            }
        }
    );
    isa_ok ( $log->loggers->[0], "Log::Handy::Output::Screen" );

    stdout_like {
        $log->critical("foo");
    } qr/foo/, "log emitted to STDOUT";
});

subtest("new with outputs and globals", sub {
    my $log = Log::Handy->new(+{
        global => +{
            min_level => "debug",
            max_level => "emergency",
        },
        outputs => +{
            "Output::Screen" => +{
                log_to => "STDOUT",
                min_level => "warn",
                max_level => "critical",
            }
        }
    });

    stdout_unlike {
        $log->debug("foo");
    } qr/foo/, "log not emitted to STDOUT because of option override";

    stdout_like {
        $log->warn("foo");
    } qr/foo/, "log emitted to STDOUT because of option override";

    $log->warn("foo", +{ foo => "bar"}, +{ log_to => "STDERR" });
});

subtest("add", sub {
    my $log = Log::Handy->new;

    stdout_unlike {
        $log->warn("foo");
    } qr/foo/, "log emitted to STDOUT because logger not added";

    $log->add(
        screen => +{
            log_to => "STDOUT",
            min_level => "warn",
            max_level => "critical",
        }
    );

    stdout_like {
        $log->warn("foo");
    } qr/foo/, "log emitted to STDOUT because logger added";

    $log->add(
        screen => +{
            log_to => "STDERR",
            min_level => "warn",
            max_level => "critical",
        }
    );

    stderr_like {
        $log->warn("foo");
    } qr/foo/, "log emitted to STDERR because logger added";
});

subtest("level_alias", sub {
    my $log = Log::Handy->new;

    $log->add(
        screen => +{
            log_to => "STDOUT",
            min_level => "warn",
            max_level => "critical",
        }
    );

    $log->level_alias("fatal", "critical");
    can_ok( $log, "fatal" );

    stdout_like {
        $log->fatal("foo");
    } qr/foo/, "we can call fatal method as critical";
});

subtest("load", sub {
    my ($fh, $tempfile) = tempfile( SUFFIX => ".pl" );
    note $tempfile;

    print $fh <<CONF;
+{
    outputs => +{
        screen => +{
            log_to => "STDOUT",
            min_level => "warn",
            max_level => "critical",
        }
    }
}
CONF

    close $fh;

    my $log = Log::Handy->load($tempfile);

    stdout_like {
        $log->warn("foo");
    } qr/foo/, "we can load conf from file";
});

done_testing;
