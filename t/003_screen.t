#!perl -w
use strict;
use Test::More;
use Test::Exception;
use Test::Output;

BEGIN {
    use_ok 'Log::Handy::Output::Screen';
}

subtest("new and log", sub {
    my $screen = Log::Handy::Output::Screen->new(+{
        opts => +{
            min_level => "warn",
            max_level => "critical",
        },
    });
    isa_ok( $screen, "Log::Handy::Output::Screen" );

    stdout_like {
        $screen->log("warn", undef, "foo bar", +{}, +{ log_to => "STDOUT" });
    } qr/foo bar/, "log emitted to STDOUT";

    stderr_like {
        $screen->log("warn", undef, "foo bar", +{}, +{ log_to => "STDERR" });
    } qr/foo bar/, "log emitted to STDERR";

});

done_testing;
