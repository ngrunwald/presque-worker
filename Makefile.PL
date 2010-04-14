use inc::Module::Install;
name 'presque-worker';
all_from 'lib/presque/worker.pm';
readme_from 'lib/presque/worker.pm';

# requires '';

tests 't/*.t';

build_requires 'Test::More';
use_test_base;
auto_include;
#auto_include_deps;
author_tests 'xt';
auto_set_repository;
WriteAll;
