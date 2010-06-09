package presque::worker::Role::Management;

use Moose::Role;

has shut_down => (is => 'rw', isa => 'Bool', default => 0,);

before start => sub {
    my $self = shift;
    $self->rest_register_worker;
    $SIG{INT}  = sub { $self->_shutdown };
    $SIG{TERM} = sub { $self->_shutdown };
    $SIG{QUIT} = sub { $self->_graceful_shutdown };
    $SIG{USR1} = sub { $self->_kill_child };
    $SIG{CHLD} = 'IGNORE';
};

after start              => sub { (shift)->rest_unregister_worker; };
after _graceful_shutdown => sub { (shift)->rest_unregister_worker; };
after _shutdown          => sub { (shift)->rest_unregister_worker; };

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

