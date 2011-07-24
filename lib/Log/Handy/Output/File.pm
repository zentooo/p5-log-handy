package Log::Handy::Output::File;

use strict;
use warnings;

use parent qw/Log::Handy::Output/;

use Data::Validator;

__PACKAGE__->mk_accessors(qw/validator fh_pool/);


sub new {
    my ($class, $opts) = @_;

    $opts->{validator} = Data::Validator->new(
        min_level => +{ isa => "Str", optional => 1 },
        max_level => +{ isa => "Str", optional => 1 },
        mode => +{ isa => "Str" },
        binmode => +{ isa => "Str", optional => 1 },
        filename => +{ isa => "Str" },
        dirname => +{ isa => "Str", optional => 1 },
        close_after_write => +{ isa => "Bool", optional => 1 },
        level_dispatch => +{ isa => "Bool", optional => 1 },
    );

    $opts->{fh_pool} = +{};

    $class->SUPER::new($opts);
}

sub log {
    my ($self, $level, $message, $options, $time) = @_;

    $options->{mode} ||= ">>";

    $self->validator->validate($options);

    my $filename = $self->_resolve_filename($level, $options, $time);
    my $fh = $self->_get_handle($filename, $options);

    print $fh $message or die "Cannot write to '$filename': $!";

    if ( $options->{close_after_write} ) {
        close $fh or die "Cannot close '$filename': $!";
    }
}

sub _get_handle {
    my ($self, $filename, $options) = @_;

    my $fh;

    if ( $options->{close_after_write} ) {
        $fh = $self->_open($filename, $options);
    }
    else {
        if ( exists $self->fh_pool->{$filename} ) {
            $fh = $self->fh_pool->{$filename};
        }
        else {
            $fh = $self->_open($filename, $options);
            $self->fh_pool->{$filename} = $fh;
        }
    }

    return $fh;
}

sub _open {
    my ($self, $filename, $options) = @_;

    open my $fh, $options->{mode}, $filename or die "Cannot open '$filename': $!";

    if ( $options->{binmode} ) {
        binmode $fh, $options->{binmode};
    }

    return $fh;
}

sub _resolve_filename {
    my ($self, $level, $options, $time) = @_;

    my $filename = $options->{dirname} ? $options->{dirname} . '/' . $options->{filename} : $options->{filename};

    if ( $filename =~ /%T\{(.*?)\}/ ) {
        my $formatted = $time->strftime($1);
        $filename =~ s/%T\{.*?\}/$formatted/;
    }

    if ( $filename =~ /%l/ ) {
        $filename =~ s/%l/$level/;
    }

    $filename =~ s/%%/%/g;

    return $filename;
}


sub DESTROY {
    my $self = shift;
    for my $filename (keys %{$self->fh_pool}) {
        close $self->fh_pool->{$filename} or die "Cannot close '$filename': $!";
    }
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
