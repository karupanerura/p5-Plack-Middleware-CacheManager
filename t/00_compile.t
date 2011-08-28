use strict;
use Test::More tests => 2;

BEGIN {
    use_ok 'Plack::Middleware::CacheManager';
    use_ok 'Plack::CacheManager';
}
