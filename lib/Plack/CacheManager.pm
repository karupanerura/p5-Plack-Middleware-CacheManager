package Plack::CacheManager;
use strict;
use warnings;

use Plack::Util::Accessor qw/cache keygen keygen_ref get_enable/;

my %keygen = ();
sub new {
    my $class = shift;
    my $option = (@_ == 1) ? $_[0] : +{ @_ };

    my $self = bless( +{ %$option } => $class );
    $self->keygen_ref("$self->{keygen}");
    $keygen{$self->keygen_ref} = $self->keygen;

    return $self;
}

sub set {
    my($self, $env, $res) = @_;

    my $key = $self->key($env);
    $self->cache->set("psgi_raw.$key" => $res) if $self->get_enable;
    $self->cache->set($key => $res->[2]);
}

sub get {
    my($self, $env, $res) = @_;

    $self->cache->get('psgi_raw.' . $self->key($env));
}

sub key {
    my($self, $env) = @_;

    _key($self->keygen_ref, $env);
}

use Memoize;
memoize('_key');
sub _key {
    my($keygen_ref, $env) = @_;

    $keygen{$keygen_ref}->($env);
}

sub DESTROY {
    my $self = shift;

    delete $keygen{$self->keygen_ref};
}

1;
