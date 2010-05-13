package presque::worker::Queue;

use Moose;

has base_uri => (
    is       => 'ro',
    isa      => 'Str',
    required => 1
);

sub push {
    my ( $self, ) = @_;
}

sub pull {
    my ( $self, ) = @_;
}

sub delete {
    my ( $self, ) = @_;
}

1;
