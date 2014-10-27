package Module::ResourcesFromPod;

use strict;
use warnings;

my $keysep = qr/[\-:=>]/;

sub _trim { $_[0] =~ s/^\s+|\s+$//g }

sub podlist2hashref {
  my $list = shift;
  die 'Not a list' unless $list and $list->[0] eq 'over-text';
  my (undef, undef, @children) = @$list;
  my %output;
  my $item = shift @children;
  while (1) {
    die 'Cannot parse list' unless $item->[0] eq 'item-text';

    my $next = $children[0];

    # merge paragraph into item
    if ($next and $next->[0] eq 'Para') {
      my $para = shift @children;
      push @$item, splice(@$para, 2);
      next;
    }

    # handle item
    if ($next and $next->[0] eq 'over-text') {
      my $key = $item->[2];
      $key =~ s/$keysep*+\s*$//;
      _trim $key;
      $output{$key} = podlist2hashref(shift @children);
    } else {
      my ($key, $value) = _handle_item($item);
      $output{$key} = $value;
    }

    last unless @children;
    $item = shift @children;
  }
  return \%output;
}

sub _handle_item {
  my $item = shift;
  die 'Not an item' unless $item and $item->[0] eq 'item-text';
  my (undef, undef, @values) = @$item;
  my ($key, $value) = split /$keysep+(?:\s+|\s*$)/, shift(@values), 2;
  _trim $key;
  $value ||= '';
  for my $child (@values) {
    if (ref $child) {
      if ($child->[0] eq 'L') {
        $value = _handle_link($child);
        last;
      } else {
        die 'Cannot parse item';
      }
    } else {
      $value .= $child;
    }
  }
  unless ($value) {
    ($key, $value) = split ' ', $key, 2;
    _trim $key;
  }
  return ($key, $value);
}

sub _handle_link {
  my $link = shift;
  die 'Not a link' unless $link and $link->[0] eq 'L';
  return $link->[1]{raw};
}

sub merge_resources {
  my ($resources, $base) = @_;
  $base ||= {};

  require CPAN::Meta::Merge;

  for my $version (qw/1.4 2/) {
    my $merger = CPAN::Meta::Merge->new(default_version => $version);
    my $data = $merger->merge($base, {resources => $resources});
    my $r = $data->{resources};
    for my $value (values %$r) {
      # return data if anything got merged
      return $data if eval { %$value };
    }
  }
  return {}
}

sub find_resources_list {
  my $tree = shift;

  my (undef, undef, @children) = @$tree;
  my $seen_header = 0;
  for my $child (@children) {
    if ($child->[0] eq 'head1' and $child->[2] eq 'RESOURCES') {
      $seen_header++;
    }
    if ($seen_header and $child->[0] eq 'over-text') {
      return $child;
    }
  }
}

sub parse_file {
  my $file = shift;

  require Pod::Simple::SimpleTree;
  my $tree = Pod::Simple::SimpleTree->new->parse_file($file)->root;

  my $list = find_resources_list $tree or return;
  my $resources = podlist2hashref $list;
  return unless %$resources;
  return merge_resources $resources;
}

1;


=head1 RESOURCES

=over

=item repository: L<http://github.com/jberger/Module-ResourcesFromPod>

=item bugtracker: L<http://github.com/jberger/Module-ResourcesFromPod/issues>

=back


