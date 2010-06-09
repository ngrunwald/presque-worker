package presque::worker::Role::Dispatcher;

use Moose::Role;
use Try::Tiny;

has fork_dispatcher => (
    is        => 'ro',
    isa       => 'Bool',
    default   => 0,
);

around work => sub {
    my ($orig, $self, $job) = @_;

    try {
        if ($self->fork_dispatcher) {
            $self->_fork_and_work($orig, $job);
        }
        else {
            $self->$orig($job);
        }
    }catch{
        $self->_job_failure($job, $_);
    };
};


sub _fork_and_work {
    my ($self, $orig, $job) = @_;

    my $pid = fork();
    if ($pid == 0) {
        $self->$orig($job);
        exit;
    }
    elsif ($pid > 0) {
        return;
    }
    else {
        # failure
    }
}

1;
