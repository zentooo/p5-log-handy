#!perl -w
use strict;
use Test::More;
use Data::Util qw/:check/;
use Data::Dump qw/dump/;

use lib 't/lib';
use Driver;

BEGIN {
    use_ok 'Log::Handy::Output';
}

my $sample_env = +{ P => "p", T => "t", F => "f", L => "l", M => "m" };

subtest("new", sub {
    my $output = Driver->create("Log::Handy::Output", +{
        log => sub {
            print "logged";
        }
    });
    isa_ok( $output, "Log::Handy::Output" );
    can_ok( $output, "call" );
    can_ok( $output, "log" );
});

subtest("simple call", sub {
    my $output = Driver->create("Log::Handy::Output", +{
        log => sub {
            my ($self, $level, $message, $options) = @_;

            ok ( 1, "log method called" );

            ok ( is_string($message) );
            ok ( is_hash_ref($options) );

            note $message;
            note explain $options;

            is ( $options->{min_level}, "debug" );
        }
    }, +{
        opts => +{
            min_level => "debug",
        },
    });
    $output->call("warn", ["logg"], $sample_env );
});

subtest("loglevel filters", sub {
    my $called = 0;

    my $output = Driver->create("Log::Handy::Output", +{
        log => sub {
            my ($self, $level, $message, $options) = @_;
            $called++;
        }
    }, +{
        opts => +{
            min_level => "warn",
            max_level => "critical",
        },
    });

    $output->call("debug", ["logg"], $sample_env );
    is ( $called, 0, "debug not called because min_level = warn" );

    $output->call("emergency", ["logg"], $sample_env );
    is ( $called, 0, "emergency not called because max_level = critical" );

    $output->call("warn", ["logg"], $sample_env );
    is ( $called, 1, "warn called because min_level = warn" );

    $output->call("critical", ["logg"], $sample_env );
    is ( $called, 2, "critical called because max_level = critical" );

    $output->call("error", ["logg"], $sample_env );
    is ( $called, 3, "critical called because it is between min and max" );
});

subtest("suppress callback", sub {
    my $called = 0;
    my $suppress_flag = 1;

    my $output = Driver->create("Log::Handy::Output", +{
        log => sub {
            my ($self, $level, $message, $options) = @_;
            $called++;
        }
    }, +{
        opts => +{
            min_level => "debug",
            suppress_callback => sub {
                $suppress_flag;
            }
        },
    });
    $output->call("warn", ["logg"], $sample_env );
    is ( $called, 0, "log call suppressed!" );

    $suppress_flag = 0;
    $output->call("warn", ["logg"], $sample_env );
    is ( $called, 1, "log call not suppressed" );
});

subtest("merging options", sub {
    my $called = 0;

    my $output = Driver->create("Log::Handy::Output", +{
        log => sub {
            my ($self, $level, $message, $options) = @_;
            note $message;
            note explain $options;

            is ( $options->{file_name}, "override.log", "file_name overriden" );
        }
    }, +{
        opts => +{
            min_level => "warn",
            max_level => "critical",
            file_name => "output.log",
        },
    });

    $output->call("warn", ["logg", +{ file_name => "override.log" }], $sample_env );
});

subtest("format time", sub {
    my $output = Log::Handy::Output->new;
    my ($time1) = $output->_format_time(+{});
    like ( $time1, qr/\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d/, "default time format" );
    my ($time2) = $output->_format_time(+{ time_format => "%Y/%m/%d" });
    like ( $time2, qr!\d\d\d\d/\d\d/\d\d!, "customized time format" );
});

subtest("join args", sub {
    my $output = Log::Handy::Output->new;
    my $message1 = $output->_join_args(["foo", "bar", "baz"], +{});
    warn dump $message1;
    like ( $message1, qr/"foo" "bar" "baz"/, "strings joined" );

    my $message2 = $output->_join_args(["foo", { "bar" => "baz"}], +{});
    note $message2;

    my $message3 = $output->_join_args(["foo", { "bar" => "baz"}], +{ dump_callback => sub { dump shift; } });
    note $message3;

    my $message4 = $output->_join_args(["foo", { "bar" => "baz"}], +{
        dump_callback => sub { dump shift; },
        separator => ", ",
    });
    note $message4;
});

subtest("format message", sub {
    my $output = Log::Handy::Output->new;
    my $message1 = $output->_format_message("warn", "foo", $sample_env, +{});
    ok ( is_string($message1) );
    ok ( $message1 !~ /%/ );
    note $message1;

    my $message2 = $output->_format_message("warn", "foo%%", $sample_env, +{});
    ok ( $message2 =~ /foo%[^%]/ );
    note $message2;
});

done_testing;
