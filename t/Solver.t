use strict; 
use warnings;
use v5.10;

use FindBin;
use local::lib "$FindBin::Bin/../perl5";
use lib "$FindBin::Bin/../../lib";
use lib "$FindBin::Bin/";
use TestSuite qw(test_suite); 

test_suite();
