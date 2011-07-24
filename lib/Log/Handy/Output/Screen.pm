package Log::Handy::Output::Screen;

use strict;
use warnings;

use parent qw/Log::Handy::Output/;

use Data::Validator;

__PACKAGE__->mk_accessors(qw/validator/);


sub new {
    my ($class, $opts) = @_;

    $opts->{validator} = Data::Validator->new(
        log_to => +{ isa => "Str" }
    )->with('AllowExtra');

    $class->SUPER::new($opts);
}

sub log {
    my ($self, $level, $message, $options) = @_;

    $self->validator->validate($options);

    if ( $options->{log_to} eq "STDOUT" ) {
        print STDOUT $message;
    }
    elsif ( $options->{log_to} eq "STDERR" ) {
        print STDERR $message;
    }
}


1;
__END__

=head1 NAME"

Log::Handy::Output::Screen - log to screen

=head1 SYNOPSIS

    use Log::Handy::Screen;

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
