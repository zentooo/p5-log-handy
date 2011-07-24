package Log::Handy::Output::File;

use strict;
use warnings;

use parent qw/Log::Handy::Output/;


sub log {
    my ($self, $level, $message, $options, $time) = @_;

    my $filename = $self->_resolve_filename($level, $options, $time);

    open my $fh, $options->{mode}, $filename or warn "Cannot open '$options->{filename}': $!";

    if ( $options->{binmode} ) {
        binmode $fh, $options->{binmode};
    }

    print $fh $message or warn "Cannot write to '$options->{filename}': $!";
    close $fh;
}

sub _resolve_filename {
    my ($self, $level, $options, $time) = @_;

    my $filename = $options->{filename};

    if ( $filename =~ /%D\{(.*?)\}/ ) {
        my $formatted = $time->strftime($1);
        $filename =~ s/%D\{.*?\}/$formatted/;
    }

    if ( $options->{level_dispatch} ) {
        $filename =~ s/%l/$level/ if $filename =~ /%l/;
    }

    return $filename;
}


1;
__END__

=head1 NAME"

Log::Handy::Output::File - log to file

=head1 SYNOPSIS

    use Log::Handy::File;

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
