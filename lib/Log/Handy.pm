package Log::Handy;

use strict;
use warnings;

use parent qw/Class::Accessor::Fast/;

__PACKAGE__->mk_accessors(qw/loggers global/);

use Carp;
use Class::Load qw/load_class/;
use String::RewritePrefix;
use Config::Any;
use Sys::Hostname;
use POSIX;
use Hash::Merge::Simple qw/clone_merge/;

our $VERSION = '0.01';

our %OUTPUT_ALIASES = (
    screen => 'Output::Screen',
    file => 'Output::File',
    syslog => 'Output::Syslog',
);

our @LEVELS;
my $env;

BEGIN {
    $env = +{
        H => Sys::Hostname::hostname,
        U => getpwuid($<) || $<,
        G =>  getgrgid($( + 0) || $( + 0,
        P => $$,
    };

    @LEVELS = qw/debug info notice warn warning err error crit critical alert emerg emergency/;

    for my $level (@LEVELS) {
        my $sub = sub {
            my ($self, @args) = @_;
            my ($module, $file, $line) = (caller(0))[0, 1, 2];
            for my $logger (@{$self->loggers}) {
                $logger->call($level, \@args, clone_merge($env, +{
                     M => $module,
                     F => $file,
                     L => $line,
                }));
            }
        };

        no strict 'refs';
        *{$level} = $sub;
    }
}


sub new {
    my ($class, $opts) = @_;

    my $global_options;

    if ( ref $opts->{global} eq 'HASH' ) {
        $opts->{global} = $global_options = $opts->{global};
    }

    if ( ref $opts->{outputs} eq 'HASH' ) {
        my $classes = _load_plugins($opts->{outputs});
        $opts->{loggers} = _init_plugins($classes, $opts->{outputs}, $global_options);
    }
    else {
        $opts->{loggers} = [];
    }

    $class->SUPER::new($opts);
}

sub _load_plugins {
    my ($outputs) = @_;

    my @classes = String::RewritePrefix->rewrite(+{
        '' => 'Log::Handy::',
        '+' => ''
    }, map {
        exists $OUTPUT_ALIASES{$_} ? $OUTPUT_ALIASES{$_} : $_;
    } keys %$outputs);

    load_class($_) for @classes;
    return \@classes;
}

sub _init_plugins {
    my ($classes, $outputs, $global_options) = @_;

    my @instances;
    my $options = [values %$outputs];

    # This loop expects that keys & values operators yield results with the same sequence.
    # If it seems ugly for you, give me better solution.
    # ex.
    # my %hash = (1 => "foo", 2 => "bar", 3 => "baz");
    # keys %hash -> 1, 2, 3
    # values %hash -> foo, bar, baz

    for ( my $i = 0; $i < scalar @$classes; ++$i ) {
        my $instance = do {
            if ( $global_options ) {
                $classes->[$i]->new( +{ opts => clone_merge($global_options, $options->[$i]) } );
            }
            else {
                $classes->[$i]->new( +{ opts => $options->[$i] } );
            }
        };
        push @instances, $instance;
    }

    return \@instances;
}

sub add {
    my ($self, %outputs) = @_;
    my $classes = _load_plugins(\%outputs);
    my $instances = _init_plugins($classes, \%outputs, $self->global);
    $self->loggers([@{$self->loggers}, @$instances]);
}

sub level_alias {
    my ($self, $to, $from) = @_;
    no strict 'refs';
    *{$to} = \&$from;
}

sub load_config {
    my ($self, $config_file) = @_;

    croak $! unless ( -f $config_file && -r $config_file );

    my $config = eval {
        Config::Any->load_files( +{ files => [$config_file], use_ext => 1 } );
    };
    if ( $@ ) {
        my $e = $@;
        croak $e;
    }

    $self->config($config->[0]);
}

sub config {
    my ($self, $config) = @_;
    $self->config($config);
}

1;

__END__

=head1 NAME"

Log::Handy - Log friendly

=head1 VERSION

This document describes Log::Handy version 0.01.

=head1 SYNOPSIS

    use Log::Handy;

=head1 DESCRIPTION

# TODO

=head1 INTERFACE

=head2 Functions

=head3 C<< hello() >>

# TODO

=head1 DEPENDENCIES

Perl 5.8.1 or later.

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 SEE ALSO

L<perl>

=head1 AUTHOR

zentooo E<lt> ankerasoy atmark gmail dot com E<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2011, zentooo. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut