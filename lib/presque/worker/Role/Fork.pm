package presque::worker::Role::Fork;

use Moose::Role;

has fork_dispatcher => (
    is        => 'ro',
    isa       => 'Bool',
    default   => 1,
    predicate => 'has_fork_dispatcher'
);

1;