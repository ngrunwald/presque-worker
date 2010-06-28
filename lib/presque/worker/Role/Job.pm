package presque::worker::Role::Job;

use Try::Tiny;
use Moose::Role;
has job_retries    => (is => 'rw', isa => 'Int', default  => 5);

sub _job_failure {
    my ($self, $job, $err) = @_;

    push @{$job->{fail}}, $err;
    my $retries = ($job->{retries_left} || $self->job_retries) - 1;
    $job->{retries_left} = $retries;
    try {
        $self->retry_job(queue_name => $self->queue_name, %$job) if $retries > 0;
    }
    catch {
        # XXX
    };
    $self->fail($job, $_) if $self->_has_fail_method;
}

1;
