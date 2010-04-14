package presque::worker;

use Moose;
our $VERSION = '0.01';

use AnyEvent;
use AnyEvent::HTTP;

use Carp;
use JSON;
use Try::Tiny;

has base_uri => ( is => 'ro', isa => 'Str', required => 1 );
has queue    => ( is => 'ro', isa => 'Str', required => 1 );
has interval => ( is => 'ro', isa => 'Int', lazy     => 1, default => 5 );

sub BUILD {
    my ( $self, $args ) = @_;
    my ( $get, $timer );

    my $uri       = $self->base_uri;
    my $queue     = $self->queue;
    my $queue_uri = $uri . '/q/' . $queue;

    if ( !$self->meta->find_method_by_name('work') ) {
        Carp::confess "method work is missing";
    }

    $get = sub {
        http_get $queue_uri, sub {
            my ( $body, $hdr ) = @_;
            return if ( !$body || $hdr->{Status} != 200 );
            my $content = JSON::decode_json($body);

            try {
                $self->work($content);
            }
            catch {
                $self->fail($content, $_) if $self->meta->find_method_by_name('fail');
            };
            $timer = AnyEvent->timer( after => $self->interval, cb => $get );
        };
    };
    $get->();
    return $self;
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

Worker must implement the B<work> method. The only argument of this method is a hashref
containing the job.

=head2 fail ($job_description, $error_reason)

Worker may implement the B<fail> method. This method have two arguments: the job description
and the reason of the failure.

=head1 AUTHOR

franck cuny E<lt>franck@lumberjaph.netE<gt>

=head1 SEE ALSO

=head1 LICENSE

Copyright 2010 by Linkfluence

L<http://linkfluence.net>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
