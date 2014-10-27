use strict;
use warnings;

use Test::More;
use CPAN::Meta;
use CPAN::Meta::Merge;

use Module::ResourcesFromPod;

sub generate {
  my $resources = shift;
  CPAN::Meta->create({
    author => ['me'],
    version => 1,
    name => 'it',
    abstract => 'does',
    license => ['unrestricted'],
    dynamic_config => 0,
    release_status => 'stable',
    $resources ? ( resources => $resources ) : (),
  });
}

my $meta = generate;
isa_ok $meta, 'CPAN::Meta';

use DDP;

my $url = 'http://github.com/jberger/it';
$meta = Module::ResourcesFromPod::merge_resources({ repository => { web => $url } });
is $meta->{resources}{repository}{web}, $url or p $meta;

$meta = Module::ResourcesFromPod::merge_resources({ repository => $url });
is $meta->{resources}{repository}{url}, $url or p $meta;

done_testing;

