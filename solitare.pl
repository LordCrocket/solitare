#!/usr/bin/perl

use strict;
use warnings;
use v5.10;

use FindBin;
use local::lib "$FindBin::Bin/perl5";
use lib "$FindBin::Bin/lib";

use Data::Dumper;
use Math::BigInt;
use Getopt::Long;

## Custom ##
use Move;
use Board;
use Solver;
use Strategy::Orphan qw (orphans_strat);
use Strategy::Points qw (points_strat);

$| = 1;
my $debug = 0;
my $marbles = 4;
my $memoize;

GetOptions ('v+' => \$debug,'m:s' => \$memoize,'n:i' => \$marbles );

my $board = Board->create_board();

$board->[0][3] = 0;
# 36 marbles
my $strategies = [\&points_strat,\&orphans_strat];
#my $strategies = [\&points_strat];
my $solver = Solver->new({debug => $debug,memoize => $memoize});
$solver->solve($board,36,$marbles,$strategies);
