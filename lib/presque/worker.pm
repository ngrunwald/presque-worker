package presque::worker;

our $VERSION = '0.01';

use Carp;
use JSON;
use Try::Tiny;
use presque::worker::Queue;

use Moose;
with qw/
  presque::worker::Role::Management
  presque::worker::Role::Fork
  presque::worker::Role::RESTClient
  presque::worker::Role::Logger/;

has queue_name => (is => 'ro', isa => 'Str', required => 1);
has retries    => (is => 'rw', isa => 'Int', default  => 5);
has interval => (is => 'ro', isa => 'Int', lazy => 1, default => 1);
has _fail_method => (
    is        => 'rw',
    isa       => 'Bool',
    lazy      => 1,
    default   => 0,
    predicate => '_has_fail_method'
);
has queue => (
    is   => 'ro',
    isa  => 'Object',
    lazy => 1,
    default =>
      sub { presque::worker::Queue->new(base_uri => (shift)->base_uri); }
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

before start => sub {
    my $self = shift;
    if (!$self->meta->find_method_by_name('work')) {
        Carp::confess "method 'work' is missing";
    }
    if ($self->meta->find_method_by_name('fail')) {
        $self->fail_method(1);
    }
};

sub start {
    my $self = shift;

    $self->logger->log(
        level   => 'info',
        message => "presque worker ["
          . $self->worker_id
          . "] : start to listen for "
          . $self->queue_name
    );

    while (!$self->shut_down) {
        my $job = $self->rest_fetch_job();
        $self->work_once($job) if $job;
        sleep($self->interval);
    }
    return $self;
}

sub work_once {
    my ($self, $job) = @_;

    try {
        $self->work($job);
    }
    catch {
        my $err = $_;
        $self->logger->log(
            level   => 'error',
            message => 'Job failed: ' . $err,
        );
        push @{$job->{fail}}, $err;
        my $retries = ($job->{retries_left} || $self->retries) - 1;
        $self->rest_retry_job($job) if $retries > 0;
        $self->fail($job, $_) if $self->_has_fail_method;
    };
}

1;
__END__

=head1 NAME

presque::worker - a presque worker

=head1 SYNOPSIS

    package myworker;
    use Moose;
    extends 'presque::worker';

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
