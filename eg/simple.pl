#!/usr/bin/env perl
use strict;
use warnings;

package myworker;
use Moose;
with 'presque::worker';

use YAML::Syck;
sub work {
    my ($self, $job) = @_;
    warn Dump $job;
    sleep(5);
}

package main;
my $w = myworker->new(
    base_uri   => 'http://localhost:5000',
    queue_name => 'foo',
    fork_dispatcher => 1,
);

$w->start;
