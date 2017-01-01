#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
$| = 1;


sub traverse_board {
    (my $board, my $e_callback,my $r_callback) = @_;
    for my $row (0 .. 6){
        foreach my $col (0 .. 6){
            $e_callback->($board,$row,$col);
        }
        $r_callback->();
    }
}



my $board = [
    [(-1) x 2, (1)x3, (-1) x 2],
    [-1, (1)x5, -1],
    [(1)x7],
    [(1)x7],
    [(1)x7],
    [-1, (1)x5, -1],
    [(-1) x 2, (1)x3, (-1) x 2],
];

my $print_sub = sub {
    (my $board,my $row, my $col) = @_;

    my $element = $board->[$row][$col];
    if($element > -1){
        printf "%2s",$element;
    }
    else {
        printf "%2s"," ";
    }
};

sub get_moves{
    (my $board,my $row, my $col) = @_;
    my $element = $board->[$row][$col];
    if(defined $element){
    }
}

$board->[0][3] = 0;
$board->[4][3] = 0;
$board->[5][3] = 0;
traverse_board($board, $print_sub, sub {print "\n"});
#print Dumper($board);
