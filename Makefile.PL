use inc::Module::Install;
name 'Plack-Middleware-CacheManager';
all_from 'lib/Plack/Middleware/CacheManager.pm';
readme_from 'lib/Plack/Middleware/CacheManager.pm';
readme_pod_from 'lib/Plack/Middleware/CacheManager.pm';
githubmeta;

# requires '';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
