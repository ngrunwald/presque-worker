package presque::worker::Role::Management;

use Moose::Role;

has shut_down => (is => 'rw', isa => 'Bool', default => 0,);

before start => sub {
    my $self = shift;
    $self->rest_register_worker
};

after start => sub {
    my $self = shift;
    $self->rest_unregister_worker;
};

# XXX reg signal

1;
