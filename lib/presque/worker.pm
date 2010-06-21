package presque::worker;

our $VERSION = '0.01';

use Carp;
use JSON;
use Try::Tiny;

use Moose::Role;
requires 'work';

with qw/
  presque::worker::Role::Management
  presque::worker::Role::Dispatcher
  presque::worker::Role::RESTClient
  presque::worker::Role::Job
  presque::worker::Role::Logger/;

has queue_name => (is => 'ro', isa => 'Str', required => 1);
has interval   => (is => 'ro', isa => 'Int', lazy     => 1, default => 1);
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

after new => sub {
    my $self = shift;
    if ($self->meta->find_method_by_name('fail')) {
        $self->fail_method(1);
    }
};

sub start {
    my $self = shift;

    while (!$self->shut_down) {
        my $job = $self->rest_fetch_job();
        $job ? $self->work($job) : $self->idle();

    }
}

sub idle {
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
