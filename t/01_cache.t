use strict;
use warnings;
use Test::More;

use Plack::Test;
use Plack::Builder;

use lib 't/lib';
use Cache::Simple;
use HTTP::Request;

my $raw_app = sub {
    my $env = shift;
    [
        200,
        [ 'Content-Type' => 'text/plain' ],
        [ $env->{REQUEST_URI} ]
    ];
};

my $cache = Cache::Simple->new();
my $app = builder {
    enable 'CacheManager', (
        cache  => $cache,
        keygen => sub {
            my $env = shift;
            return $env->{REQUEST_URI};
        },
        expire => 1,
        work   => [qw/set get/],
    );
    $raw_app;
};

subtest 'raw app is ok' => sub {
    foreach my $request_uri (qw{/ /test /test/test /test?foo=bar}) {
        test_psgi
            app => $raw_app,
            client => sub {
                my $cb = shift;
                my $req = HTTP::Request->new(GET => "http://localhost${request_uri}");
                my $res = $cb->($req);
                is $res->content, $request_uri;
            };
    }
    done_testing;
};

subtest 'wrapped app is ok' => sub {
    foreach my $request_uri (qw{/ /test /test/test /test?foo=bar}) {
        test_psgi
            app => $app,
            client => sub {
                my $cb = shift;
                my $req = HTTP::Request->new(GET => "http://localhost${request_uri}");
                my $res = $cb->($req);
                is $res->content, $request_uri;
            };
    }
    done_testing;
};

subtest 'cache ok' => sub {
    foreach my $request_uri (qw{/ /test /test/test /test?foo=bar}) {
        test_psgi
            app => $app,
            client => sub {
                my $cb = shift;
                my $req = HTTP::Request->new(GET => "http://localhost${request_uri}");
                my $res = $cb->($req);
                is $res->content, $request_uri;
            };
        is $cache->get($request_uri), $request_uri, 'cached ok';
        $cache->set("psgi_raw.$request_uri", [200, ['Content-Type' => 'text/plain'], ['hoge']], 1);
        test_psgi
            app => $app,
            client => sub {
                my $cb = shift;
                my $req = HTTP::Request->new(GET => "http://localhost${request_uri}");
                my $res = $cb->($req);
                is $res->content, 'hoge', 'cached ok';
            };
        sleep(1); # expire
        test_psgi
            app => $app,
            client => sub {
                my $cb = shift;
                my $req = HTTP::Request->new(GET => "http://localhost${request_uri}");
                my $res = $cb->($req);
                is $res->content, $request_uri, 'expire ok';
            };
        is $cache->get($request_uri), $request_uri, 'new cache ok';
    }
    done_testing;
};

done_testing;
1;
