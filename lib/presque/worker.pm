package presque::worker;

our $VERSION = '0.01';

use Carp;
use JSON;
use Try::Tiny;

use Moose::Role;
use Net::Presque;

requires 'work';

with qw/
  presque::worker::Role::Management
  presque::worker::Role::Dispatcher
  presque::worker::Role::Job
  presque::worker::Role::Context
  presque::worker::Role::Logger/;

has queue_name => (
    is      => 'rw',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
        my $self = shift;
        if ($self->context->{queue_name}) {
            return $self->context->{queue_name};
        }
        die "queue_name is missing!";
    }
);
has interval => (
    is      => 'rw',
    isa     => 'Int',
    lazy    => 1,
    default => sub {
        my $self = shift;
        if ($self->context->{interval}) {
            return $self->context->{interval};
        }
        return 1;
    }
);
has _fail_method => (
    is        => 'rw',
    isa       => 'Bool',
    lazy      => 1,
    default   => 0,
    predicate => '_has_fail_method'
);
has worker_id => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    default  => sub {
        my $self = shift;
        my $name = $self->meta->name . '_' . $$;
        $name;
    }
);
has rest_client => (
    is      => 'rw',
    isa     => 'Net::Presque',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $client =
          Net::Presque->new(api_base_url => $self->context->{rest}->{url});
        $client;
    },
    handles => {
        pull              => 'fetch_job',
        retry_job         => 'failed_job',
        register_worker   => 'register_worker',
        unregister_worker => 'unregister_worker'
    }
);

after new => sub {
    my $self = shift;
    if ($self->meta->find_method_by_name('fail')) {
        $self->fail_method(1);
    }
};

sub start {
    my $self = shift;

    while (!$self->shut_down) {
        my $job = try {
            $self->pull(queue_name => $self->queue_name, worker_id => $self->worker_id);
        };
        $job ? $self->work($job) : $self->idle();
    }
}

sub idle {
    my $self = shift;
    sleep($self->interval);
}

1;
__END__

=head1 NAME

presque::worker - a presque worker

=head1 SYNOPSIS

    package myworker;
    use Moose;
    with 'presque::worker';

    sub work {
        my ($self, $job) = @_;
        ...
    }

    sub fail {
        my ($self, $job, $error) = @_;
        ...
    }

=head1 DESCRIPTION

presque::worker - Worker for the C<presque> message queue system

=head1 METHODS

=head2 work ($job_description)

Worker must implement the B<work> method. The only argument of this method is a hashref containing the job.

=head2 fail ($job_description, $error_reason)

Worker may implement the B<fail> method. This method have two arguments: the job description and the reason of the failure.

=head2 idle

If no job, the worker execute the method B<idle>. By default, this method will sleep a number of seconds defined in the B<interval> attribute.

=head1 ATTRIBUTES

=head2 queue_name

=head2 base_uri

=head2 worker_id

=head2 retries

=head2 interval

=head2

The url of the presque webservices.

=head1 AUTHOR

franck cuny E<lt>franck@lumberjaph.netE<gt>

=head1 SEE ALSO

=head1 LICENSE

Copyright 2010 by Linkfluence

L<http://linkfluence.net>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
