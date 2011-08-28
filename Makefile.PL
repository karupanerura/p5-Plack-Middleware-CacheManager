use inc::Module::Install;
name 'Plack-Middleware-CacheManager';
all_from 'lib/Plack/Middleware/CacheManager.pm';
readme_from 'lib/Plack/Middleware/CacheManager.pm';
readme_pod_from 'lib/Plack/Middleware/CacheManager.pm';
githubmeta;

build_requires 'HTTP::Request';
build_requires 'Plack::Test';
build_requires 'Plack::Builder';
build_requires 'Test::More';
requires 'parent';
requires 'Plack::Util::Accessor';

tests 't/*.t';
author_tests 'xt';

auto_set_repository;
auto_include;
WriteAll;
