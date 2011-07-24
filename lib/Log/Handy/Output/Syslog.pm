package Log::Handy::Output::Syslog;

use strict;
use warnings;

use parent qw/Log::Handy::Output/;

use Data::Validator;
use Sys::Syslog qw/openlog syslog closelog/;

__PACKAGE__->mk_accessors(qw/validator/);

my %LEVEL_MAP = (
    warn => "warning",
    error => "err",
    critical => "crit",
    emergency => "emerg",
);


sub new {
    my ($class, $opts) = @_;

    $opts->{validator} = Data::Validator->new(
        min_level => +{ isa => "Str", optional => 1 },
        max_level => +{ isa => "Str", optional => 1 },
        ident => +{ isa => "Str" },
        logopt => +{ isa => "Str" },
        facility => +{ isa => "Str" },
    );

    $class->SUPER::new($opts);
}

sub log {
    my ($self, $level, $message, $options) = @_;

    $options->{logopt} ||= "nowait,pid";
    $options->{facility} ||= "user";

    $self->validator->validate($options);

    eval {
        openlog($options->{ident}, $options->{logopt}, $options->{facility});
        syslog($self->_level_as_prioity($level), $message);
        closelog;
    };
    if ( $@ ) {
        my $e = $@;
        warn $e;
    }
}

sub _level_as_prioity {
    my ($self, $level) = @_;

    if ( exists $LEVEL_MAP{$level} ) {
        return $LEVEL_MAP{$level};
    }
    else {
        return $level;
    }
}


1;
__END__

=head1 NAME"

Log::Handy::Output::Syslog - log to syslog

=head1 SYNOPSIS

    use Log::Handy::Syslog;

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
