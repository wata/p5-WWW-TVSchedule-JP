package WWW::TVSchedule::JP;
use strict;
use warnings;
our $VERSION = '0.01';
use utf8;
use Cache::FileCache;
use Web::Scraper;
use URI;

sub new {
    my $class = shift;
    my $opt   = @_;
    my $cache = Cache::FileCache->new($opt || {
        cache_root         => '/tmp',
        namespace          => 'WWW-TVSchedule-JP',
        default_expires_in => '1d',
    });

    my $drama = $cache->get('drama');
    my $anime = $cache->get('anime');
    unless ($drama && $anime) {
        $drama = _scrape_drama->(URI->new('http://tv.so-net.ne.jp/drama/'));
        $anime = _scrape_anime->(URI->new('http://tv.so-net.ne.jp/anime/'));
        $cache->set('drama', $drama);
        $cache->set('anime', $anime);
    }

    bless { drama => $drama, anime => $anime }, $class;
}

sub _scrape_drama {
    my $url = shift;

    my $res = scraper {
        process '.box', 'entries[]' => scraper {
            process 'h2 img', 'wdayname' => [ '@src',
                sub { /h_([a-z]{3})_b\.png$/; $1; }
            ];
            process 'dt', 'program[]' => scraper {
                process 'a, span', 'title' => 'TEXT';
            };
        };
    }->scrape($url);

    return +{
        $res->{entries}[0]->{wdayname} => $res->{entries}[0]->{program},
        $res->{entries}[1]->{wdayname} => $res->{entries}[1]->{program},
        $res->{entries}[2]->{wdayname} => $res->{entries}[2]->{program},
        $res->{entries}[3]->{wdayname} => $res->{entries}[3]->{program},
        $res->{entries}[4]->{wdayname} => $res->{entries}[4]->{program},
        $res->{entries}[5]->{wdayname} => $res->{entries}[5]->{program},
        $res->{entries}[6]->{wdayname} => $res->{entries}[6]->{program},
    }
}

sub _scrape_anime {
    my $url = shift;

    my $res = scraper {
        process '.txt', 'program[]' => scraper {
            process 'p', 'wdayname' => [ 'HTML',
                sub { /(.{1}) [0-9:]+<br \/>/; $1; }
            ];
            process 'h2', 'title' => 'TEXT';
        };
    }->scrape($url);

    my @mon = map { +{ title => $_->{title} } }
        grep { $_->{wdayname} eq '月' } @{ $res->{program} };
    my @tue = map { +{ title => $_->{title} } }
        grep { $_->{wdayname} eq '火' } @{ $res->{program} };
    my @wed = map { +{ title => $_->{title} } }
        grep { $_->{wdayname} eq '水' } @{ $res->{program} };
    my @thu = map { +{ title => $_->{title} } }
        grep { $_->{wdayname} eq '木' } @{ $res->{program} };
    my @fri = map { +{ title => $_->{title} } }
        grep { $_->{wdayname} eq '金' } @{ $res->{program} };
    my @sat = map { +{ title => $_->{title} } }
        grep { $_->{wdayname} eq '土' } @{ $res->{program} };
    my @sun = map { +{ title => $_->{title} } }
        grep { $_->{wdayname} eq '日' } @{ $res->{program} };

    return +{
        'mon' => \@mon, 'tue' => \@tue, 'wed' => \@wed, 'thu' => \@thu,
        'fri' => \@fri, 'sat' => \@sat, 'sun' => \@sun,
    };
}

sub drama {
    my ($self, $wdayname) = @_;
    # array ref or hash ref
    return $wdayname ? $self->{drama}->{$wdayname} : $self->{drama};
}

sub anime {
    my ($self, $wdayname) = @_;
    # array ref or hash ref
    return $wdayname ? $self->{anime}->{$wdayname} : $self->{anime};
}

1;
__END__

=head1 NAME

WWW::TVSchedule::JP -

=head1 SYNOPSIS

  use WWW::TVSchedule::JP;
  my $tvshedule = Acme::TVShedule::JP->new({
      'cache_root'         => '/tmp',
      'namespace'          => 'hoge',
      'default_expires_in' => '30d',
  });

  # return as hash ref
  $tvshedule->drama;
  $tvshedule->anime;

  # return as array ref
  $tvshedule->drama('mon');
  $tvshedule->anime('sun');

=head1 DESCRIPTION

WWW::TVSchedule::JP is

=head1 AUTHOR

Wataru Nagasawa E<lt>nagasawa {at} junkapp.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
