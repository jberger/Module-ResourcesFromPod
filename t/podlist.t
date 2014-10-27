use strict;
use warnings;

use Test::More;

use Pod::Simple::SimpleTree;

my $pod = Pod::Simple::SimpleTree->new->parse_string_document(<<'POD')->root;
=head1 RESOURCES

=over

=item item1

value1

=item item2: value2

=item item3 - value3

=item item4

=over

=item item41 value41

=back

=item item5
value5

=back
POD

use Module::ResourcesFromPod;
use Data::Dumper;

my $hashref = Module::ResourcesFromPod::podlist2hashref($pod->[3]);

my $expect = {
  item1 => 'value1',
  item2 => 'value2',
  item3 => 'value3',
  item4 => { item41 => 'value41' },
  item5 => 'value5',
};

is_deeply $hashref, $expect, 'pod structure' or diag Dumper $hashref;



$pod = Pod::Simple::SimpleTree->new->parse_string_document(<<'POD')->root;
=head1 RESOURCES

=over

=item item1

L<http://my.site.com>

=item item2 L<http://other.site.com>

=item item3: 

=over

=item item31

L<http://inner.site.com>

=back

=back
POD

$hashref = Module::ResourcesFromPod::podlist2hashref($pod->[3]);

$expect = {
  item1 => 'http://my.site.com',
  item2 => 'http://other.site.com',
  item3 => { item31 => 'http://inner.site.com' },
};

is_deeply $hashref, $expect, 'link extraction' or diag Dumper $hashref;

done_testing;

