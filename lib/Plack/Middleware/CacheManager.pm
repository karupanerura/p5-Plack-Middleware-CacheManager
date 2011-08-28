package Plack::Middleware::CacheManager;
use strict;
use warnings;
our $VERSION = '0.01';

use parent qw/Plack::Middleware/;
use Plack::CacheManager;
use Plack::Util::Accessor qw/set_enable get_enable cache_mger cache keygen work/;

sub prepare_app {
    my $self = shift;

    $self->work([]) unless defined $self->work;
    $self->get_enable( grep(/^set$/i, @{ $self->work() }) ) unless defined $self->get_enable;
    $self->set_enable( grep(/^get$/i, @{ $self->work() }) ) unless defined $self->set_enable;
    unless ( $self->cache_mger ) {
        $self->cache_mger(
            Plack::CacheManager->new(
                keygen     => $self->keygen,
                cache      => $self->cache,
                get_enable => $self->get_enable,
            )
        );
    }
}

sub call {
    my($self, $env) = @_;

    if ($self->get_enable) {
        my $res = $self->cache_mger->get($env);
        return $res if($res);
    }
    $env->{'psgix.cache_mger'} = $self->cache_mger;

    my $res = $self->app->($env);

    if ( # don't cache streaming content
        $self->set_enable &&
        (ref($res) eq 'ARRAY')  &&
        ($res->[0] == 200) &&
        (ref($res->[2]) eq 'ARRAY')
    ) {
        $self->cache_mger->set($env, $res);
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
          cache  => Cache::Memcached::Fast->new(%memd_opt),
          keygen => sub {
              my $env = shift;
              return $env->{REQUEST_URI};
          },
          expire => 60,
          work   => ['set'],
      };
      $app;
  };

=head1 DESCRIPTION

Plack::Middleware::CacheManager is content cache manager.

=head1 AUTHOR

Kenta Sato E<lt>karupa@cpan.orgE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
