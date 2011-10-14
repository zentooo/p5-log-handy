package Log::Handy::Output;

use strict;
use warnings;

use parent qw/Class::Accessor::Fast/;

use Time::Piece ();
use Hash::Merge::Simple qw/clone_merge/;

__PACKAGE__->mk_accessors(qw/opts/);

my %level_map = (
    debug => 1,
    info => 2,
    notice => 3,
    warn => 4,
    warning => 4,
    err => 5,
    error => 5,
    crit => 6,
    critical => 6,
    alert => 7,
    emerg => 8,
    emergency => 8,
);


sub call {
    my ($self, $level, $msg, $runtime_options, $env) = @_;

    if ( ref $self->opts->{suppress_callback} eq "CODE" ) {
        return if $self->opts->{suppress_callback}->($level, $msg, $runtime_options, $env);
    }

    my $l = $level_map{$level};
    my $min = $self->opts->{min_level} ? $level_map{$self->opts->{min_level}} : 1;
    my $max = $self->opts->{max_level} ? $level_map{$self->opts->{max_level}} : 8;

    if ( $min <= $l && $l <= $max ) {
        # override global options with runtime options if there are
        my $options = $runtime_options ? clone_merge($self->opts, $runtime_options) : clone_merge($self->opts);

        my $environment = clone_merge($env);

        my $time;
        ($environment->{T}, $time) = $self->_format_time($options);

        my $formatted = $self->_format_message($level, $msg, $environment, $options);

        $self->log($level, "$formatted\n", $options, $time);
    }
}

sub _format_time {
    my ($self, $options) = @_;
    my $time_format = $options->{time_format} ? $options->{time_format} : '%Y-%m-%d %H:%M:%S';
    my $t = Time::Piece::localtime();
    return ($t->strftime($time_format), $t);
}

sub _format_message {
    my ($self, $level, $message, $env, $options) = @_;
    my $message_format = $options->{message_format} ? $options->{message_format} : '[%T] [%l %M] %m (file: %F, line: %L, pid: %P)';

    $message_format =~ s/%l/$level/;
    $message_format =~ s/%m/$message/;

    my @placeholders = ($message_format =~ /%[A-Z]/g);

    for my $placeholder (@placeholders) {
        my $value = $env->{substr($placeholder, 1)};
        $message_format =~ s/$placeholder/$value/ if defined $value;
    }

    $message_format =~ s/%%/%/g;

    return $message_format;
}

sub _validate {
    my ($self, $options) = @_;

    $self->validator->validate($options);

    if ( $self->validator->has_errors ) {
        my $errors = $self->validator->clear_errors;
        die join(", ", map { $_->{message} } @$errors) . " with " . ref $self;
    }
}

1;
__END__

=head1 NAME"

Log::Handy::Output - parent for all output plugins for Log::Handy

=head1 SYNOPSIS

    use parent qw/Log::Handy::Output/;

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
