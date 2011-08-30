package Driver;

use strict;
use warnings;


our @ISA = ();

sub create {
    my ($class, $parent, $subs, $opts) = @_;

    eval "require $parent";
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
