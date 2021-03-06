#!perl
use strict;
use warnings;
BEGIN {
    unshift @INC, 'inc';

    # author requires, or bundled modules
    my @devmods = qw(
        inc::Module::Install             1.00
        Module::Install::AuthorTests     0.002
        Module::Install::Repository      0.06
        Test::Requires                   0.06
    );
    my @not_available;
    while(my($mod, $ver) = splice @devmods, 0, 2) {
        eval qq{use $mod $ver (); 1} or push @not_available, $mod;
    }
    if(@not_available) {
        print qq{# The following modules are not available.\n};
        print qq{# `perl $0 | cpanm` will install them:\n};
        print $_, "\n" for @not_available;
        exit 1;
     }
}
use inc::Module::Install;

all_from 'lib/Log/Handy.pm';

requires 'Class::Accessor::Fast';
requires 'String::RewritePrefix';
requires 'Time::Piece';
requires 'Config::Any';
requires 'Data::Validator';
requires 'Sys::Hostname';
requires 'Hash::Merge::Simple';

test_requires 'Test::More'     => '0.88';
test_requires 'Test::Exception';
test_requires 'Test::Output';
test_requires 'Data::Util';
test_requires 'File::Temp';
test_requires 'Time::Piece';
test_requires 'Test::Requires' => '0.06';

tests_recursive;

clean_files qw(
    Log-Handy-*
    *.stackdump
    cover_db *.gcov *.gcda *.gcno
    nytprof
    *.out
);

WriteAll(check_nmake => 0);
