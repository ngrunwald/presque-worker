package presque::worker::Role::RESTClient;

use Moose::Role;

use LWP::UserAgent;
use HTTP::Request;
use MooseX::Types::URI qw/Uri/;

has base_uri => (is => 'ro', isa => Uri, coerce => 1, required => 1);
has ua => (
    is      => 'rw',
    isa     => 'LWP::UserAgent',
    lazy    => 1,
    default => sub { my $ua = LWP::UserAgent->new; $ua }
);

sub _job_uri {
    my $self = shift;
    my $uri  = $self->base_uri->clone;
    $uri->path_segments($uri->path_segments, 'q', $self->queue_name);
    $uri->query_form(worker_id => $self->worker_id);
    $uri;
}

sub _worker_uri {
    my $self = shift;
    my $uri  = $self->base_uri->clone;
    $uri->path_segments($uri->path_segments, 'w', $self->queue_name);
    $uri;
}

sub rest_register_worker {
    my $self = shift;
    my $request = HTTP::Request->new(POST => $self->_worker_uri);
    $request->content(JSON::encode_json({worker_id => $self->worker_id}));
    my $res = $self->ua->request($request);
    die "can't register to ".$self->base_uri if (!$res->is_success);
}

sub rest_unregister_worker {
    my $self = shift;
    my $request = HTTP::Request->new(DELETE => $self->_worker_uri);
    $request->query_path(worker_id => $self->worker_id);
    my $res = $self->ua->request($request);
}

sub rest_fetch_job {
    my ($self,) = @_;

    my $res = $self->ua->request(HTTP::Request->new(GET => $self->_job_uri));
    if ($res->is_success) {
        return JSON::decode_json($res->content);
    }
    else {
        $self->logger->log(
            level   => 'debug',
            message => $res->code . ':' . $res->message
        );
    }
}

sub rest_retry_job {
    my ($self, $job) = @_;

    my $request = HTTP::Request->new(PUT => $self->_job_uri);
    $request->content(JSON::encode_json($job));
    my $res = $self->ua->request($request);
    if (!$res->is_success) {
        $self->logger->log(
            level   => 'error',
            message => 'failed to update job ('
              . $res->code . ':'
              . $res->reason . ')',
        );
    }
}

1;
