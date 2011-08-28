package Cache::Simple;
use strict;
use warnings;

sub new {
    my $class = shift;
    my $opt = (@_ == 1) ? $_[0] || +{} : +{ @_ };

    bless(+{ %$opt } => $class);
}

sub set {
    my($self, $key, $value, $expire) = @_;

    $self->{_cache}{$key} = +{
        value => $value,
        $expire ? (
            destoroy_at => time + $expire,
        ) : (),
    };
}

sub get {
    my($self, $key) = @_;

    my $data = $self->{_cache}{$key};
    if ($data->{destoroy_at} && $data->{destoroy_at} <= time) {
        delete $self->{_cache}{$key};
        return;
    }
    return $data->{value};
}

1;
