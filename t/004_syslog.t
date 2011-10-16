#!perl -w
use strict;
use Test::More;
use Test::Exception;

use Test::Mock::Guard qw/mock_guard/;

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
    my $syslog = Log::Handy::Output::Syslog->new(+{ opts => $opts });
    isa_ok( $syslog, "Log::Handy::Output::Syslog" );

    my ($level, $msg);

    my $guard = mock_guard("Sys::Syslog", +{
        openlog => sub { return 1; },
        closelog => sub { return 1; },
        syslog => sub { ($level, $msg) = @_; }
    });

    $syslog->log("warn", "foo bar", $opts);

    is( $level, "warning", "log level is mapped to priority" );
    like( $msg, qr/foo bar/, "log message passed" );
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

    my $syslog = Log::Handy::Output::Syslog->new(+{ opts => $opts1 });

    my $guard = mock_guard("Sys::Syslog", +{
        openlog => sub { return 1; },
        closelog => sub { return 1; },
        syslog => sub { return 1; }
    });

    lives_ok {
        $syslog->log("warn", "foo", $opts1);
    } "we can omit logopt and facility because of default value";

    dies_ok {
        $syslog->log("warn", "foo", $opts2);
    } "we cannot omit ident because its is mandatory parameter";
});

done_testing;
