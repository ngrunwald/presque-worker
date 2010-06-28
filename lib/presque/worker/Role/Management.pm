package presque::worker::Role::Management;

use Moose::Role;

has shut_down => (is => 'rw', isa => 'Bool', default => 0,);

before start => sub {
    my $self = shift;
    $self->register_worker(worker_id => $self->worker_id);
    $SIG{INT}  = sub { $self->_shutdown };
    $SIG{TERM} = sub { $self->_shutdown };
    $SIG{QUIT} = sub { $self->_graceful_shutdown };
    $SIG{USR1} = sub { $self->_kill_child };
    $SIG{CHLD} = 'IGNORE';
};

after start => sub {
    my $self = shift;
    $self->unregister_worker(worker_id => $self->worker_id);
};
after _graceful_shutdown => sub {
    my $self = shift;
    $self->unregister_worker(worker_id => $self->worker_id);
};
after _shutdown => sub {
    my $self = shift;
    $self->unregister_worker(worker_id => $self->worker_id);
};

sub _shutdown {
    my $self = shift;
    $self->shut_down(1);
    $self->_kill_child();
}

sub _graceful_shutdown {
    my $self = shift;
    $self->shut_down(1);
    $self->_kill_child();
}

sub _kill_child {
    my $self = shift;
}

1;

