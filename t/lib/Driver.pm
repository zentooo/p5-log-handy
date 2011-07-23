package Driver;

use strict;
use warnings;

use Class::Load qw/load_class/;

our @ISA = ();

sub create {
    my ($class, $parent, $subs, $opts) = @_;

    load_class($parent);
    push @ISA, $parent;

    for my $subname (keys %$subs) {
        no strict 'refs';
        no warnings 'redefine';
        *{$subname} = $subs->{$subname};
    }

    return $class->SUPER::new($opts);
}

DESTROY {
    @ISA = ();
};

1;
