#!perl -w
use strict;
use Test::More;

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

    #for my $level (@Log::Handy::LEVELS) {
        #$screen->log($level, "foo", $opts);
    #}
});

done_testing;
