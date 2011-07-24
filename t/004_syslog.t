#!perl -w
use strict;
use Test::More;
use Test::Exception;

use Log::Handy;

BEGIN {
    use_ok 'Log::Handy::Output::Syslog';
}

subtest("new and log", sub {
    my $opts = +{
        min_level => "warn",
        max_level => "critical",
        ident => "Log::Handy test",
        logopt => "ndelay,pid",
        facility => "user",
    };
    my $screen = Log::Handy::Output::Syslog->new(+{ opts => $opts });
    isa_ok( $screen, "Log::Handy::Output::Syslog" );

    for my $level (@Log::Handy::LEVELS) {
        lives_ok {
            $screen->log($level, "foo", $opts);
        } "$level level syslog output not died";
    }
});

subtest("params omit", sub {
    my $opts1 = +{
        min_level => "warn",
        max_level => "critical",
        ident => "Log::Handy test",
    };
    my $opts2 = +{
        min_level => "warn",
        max_level => "critical",
    };

    my $screen = Log::Handy::Output::Syslog->new(+{ opts => $opts1 });
    isa_ok( $screen, "Log::Handy::Output::Syslog" );

    lives_ok {
        $screen->log("warn", "foo", $opts1);
    } "we can omit logopt and facility because of default value";

    dies_ok {
        $screen->log("warn", "foo", $opts2);
    } "we cannot omit ident because its is mandatory parameter";
});

done_testing;
