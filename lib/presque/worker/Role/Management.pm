package presque::worker::Role::Management;

use Moose::Role;

has shut_down => (is => 'rw', isa => 'Bool', default => 0,);

before start => sub {
    my $self = shift;
    $self->rest_register_worker;
};

after start => sub {
    my $self = shift;
    $self->rest_unregister_worker;
};

before start => sub {
    my $self = shift;
    $SIG{'INT'}  = sub { $self->_shutdown };
    $SIG{'TERM'} = sub { $self->_shutdown };
    $SIG{'QUIT'} = sub { $self->_graceful_shutdown };
    $SIG{'USR1'} = sub { $self->_kill_child };
};

sub _shutdown {
    my $self = shift;
    $self->logger->log(
        level   => 'info',
        message => 'worker ' . $self->worker_id . ' shuting down'
    );
    $self->shut_down(1);
    $self->_kill_child();
}

sub _graceful_shutdown {
    my $self = shift;
    $self->logger->log(
        level   => 'info',
        message => 'worker ' . $self->worker_id . ' kill child'
    );
    $self->shut_down(1);
    $self->_kill_child();
}

sub _kill_child {
    my $self = shift;
    $self->logger->log(
        level   => 'info',
        message => 'worker ' . $self->worker_id . ' shuting down gracefuly'
    );
}

1;

