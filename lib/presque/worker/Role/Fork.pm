package presque::worker::Role::Fork;

use Moose::Role;

has fork_dispatcher => (
    is        => 'ro',
    isa       => 'Bool',
    default   => 0,
);

1;
