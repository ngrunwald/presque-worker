package presque::worker::Role::Logger;

use Moose::Role;
use Log::Dispatch;
use Log::Dispatch::Screen;

has logger => (
    is      => 'rw',
    isa     => 'Object',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $log  = Log::Dispatch->new();
        $log->add(
            Log::Dispatch::Screen->new(
                name      => 'screen',
                min_level => 'debug',
                newline   => 1,
            )
        );
    }
);

before start => sub {
    my $self = shift;

    $self->logger->log(
        level   => 'info',
        message => "presque worker ["
          . $self->worker_id
          . "] : start to listen for "
          . $self->queue_name
    );
};

before work => sub {
    my $self = shift;
    $self->logger->log(
        level   => 'debug',
        message => $self->worker_id . ' start to work',
    );
};

before _shutdown => sub {
    my $self = shift;
    $self->logger->log(
        level   => 'info',
        message => 'worker ' . $self->worker_id . ' shuting down'
    );
};

before _graceful_shutdown => sub {
    my $self = shift;
    $self->logger->log(
        level   => 'info',
        message => 'worker ' . $self->worker_id . ' kill child'
    );
};

before _kill_child => sub {
    my $self = shift;
    $self->logger->log(
        level   => 'info',
        message => 'worker ' . $self->worker_id . ' shuting down gracefuly'
    );
};

1;
