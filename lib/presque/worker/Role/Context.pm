package presque::worker::Role::Context;

use YAML;

use Moose::Role;
use Moose::Util::TypeConstraints;

subtype 'Context' => as 'HashRef';

coerce 'Context' => from 'Str' => via { YAML::LoadFile $_; };

has context => (
    is      => 'rw',
    isa     => 'Context',
    lazy    => 1,
    coerce  => 1,
    default => sub {{}},
);

1;
