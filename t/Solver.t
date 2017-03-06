use strict; 
use warnings;
use v5.10;

use FindBin;
use local::lib "$FindBin::Bin/../perl5";
use lib "$FindBin::Bin/../lib";
use Test::More tests => 6;

use Solver;
use Board;

sub add_marble {
    my ($row,$col,$board) = @_;
    $board->[$row][$col] = 1;
}

sub simple_test {
    my ($solver,$board,$marbles) = @_;
    ok($solver->solve($board,1,[]), "Simple solvable board $marbles marbles") or diag explain $board->print();
}

sub simple_unsolv_test {
    my ($solver,$board,$marbles) = @_;
    ok($solver->solve($board,1,[]) == 0, "Simple unsolvable board $marbles marbles") or diag explain $board->print();
}

my $board = Board->create_board(0);
my $marbles = 2;
add_marble(3,3,$board);
add_marble(3,4,$board);
my $solver = Solver->new({debug => 0,memoize => 0,quiet => 1});

my @positions = ([4,5],[2,4],[1,3],[3,2],[4,4]);
foreach my $pos (@positions) { 
    add_marble($pos->[0],$pos->[1],$board);
    $marbles += 1;
    simple_test($solver,$board,$marbles);
}


add_marble(0,2,$board);
$marbles += 1;
simple_unsolv_test($solver,$board,$marbles);

#my $board = Board->create_board(0);
