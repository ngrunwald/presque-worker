package presque::worker::Role::Logger;

use Moose::Role;
use Log::Dispatch;
use Log::Dispatch::Screen;

has logger => (
    is      => 'rw',
    isa     => 'Object',
    lazy    => 1,
    default => sub {
        my $self    = shift;
        my $context = $self->context;
        my $logger  = Log::Dispatch->new();
        if (my $log_conf = $context->{logger}) {
            foreach my $log_type (keys %{$log_conf}) {
                my $log_engine = $self->_load_log_engine($log_type);
                my $_logger =
                  $log_engine->new(%{$self->context->{log}->{$log_type}});
                $logger->add($_logger);
            }
        }
        else {
            $log->add(
                Log::Dispatch::Screen->new(
                    name      => 'screen',
                    min_level => 'debug',
                    newline   => 1,
                )
            );
        }
        $log;
    }
);

sub _load_log_engine {
    my ($self, $engine) = @_;
    my $log_engine = "Log::Dispatch::" . ucfirst($engine);
    Class::MOP::load_class($log_engine);
    $log_engine;
}

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
