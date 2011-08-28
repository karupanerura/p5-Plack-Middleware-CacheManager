package Plack::Middleware::CacheManager;
use strict;
use warnings;
our $VERSION = '0.01';

use parent qw/Plack::Middleware/;
use Plack::CacheManager:
use Plack::Util qw/TRUE FALSE/;
use Plack::Util::Accessor qw/set_enable get_enable cache_mger cache work/;

sub prepare_app {
    my $self = shift;

    $self->cache_mger( Plack::CacheManager->new($self->cache) ) unless $self->cache_mger;
    $self->get_enable( grep(/^set$/i, @{$self->work}) ? TRUE : FALSE ) unless $self->get_enable;
    $self->set_enable( grep(/^get$/i, @{$self->work}) ? TRUE : FALSE ) unless $self->set_enable;
}

sub call {
    my($self, $env) = @_;

    return $self->cache_mger->get($env) if $self->get_enable;

    my $res = $self->app->($env);

    if (
        $self->set_enable &&
        (ref($res) eq 'ARRAY')  &&
        (ref($res->[2]) eq 'ARRAY')
    ) {
        $self->cache_mger->set($res);
    }

    return $res;
}

1;
__END__

=head1 NAME

Plack::Middleware::CacheManager - Content cache manager

=head1 SYNOPSIS

  use Plack::Builder;
  use Cache::Memcached::Fast;

  builder {
      enable 'CacheManager' => +{
          cache => Cache::Memcached::Fast->new(%memd_opt),
          key   => sub {
              my $env = shift;
              return sprintf('%s://%s%s', $env->{'psgi.url_scheme'}, $env->{HTTP_HOST}, $env->{REQUEST_URI});
          },
          expire => 60,
          work   => ['set'],
      };
      $app;
  };

=head1 DESCRIPTION

Plack::Middleware::CacheManager is

=head1 AUTHOR

Kenta Sato E<lt>karupa@cpan.orgE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
