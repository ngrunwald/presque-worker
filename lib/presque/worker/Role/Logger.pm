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

1;
