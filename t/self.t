use strict;
use warnings;

use Test::More;

use Module::ResourcesFromPod;

my $path = $INC{'Module/ResourcesFromPod.pm'};

my $meta = Module::ResourcesFromPod::parse_file($path);

my $expect = {
  repository => { url => 'http://github.com/jberger/Module-ResourcesFromPod' },
  bugtracker => { web => 'http://github.com/jberger/Module-ResourcesFromPod/issues' },
};

is_deeply $meta->{resources}, $expect;

done_testing;

