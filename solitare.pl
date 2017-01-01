#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
$| = 1;
my $pad = 2;


sub traverse_board {
    (my $board, my $e_callback,my $r_callback) = @_;
    for my $row (0+$pad .. 6+$pad){
        foreach my $col (0+$pad .. 6+$pad){
            $e_callback->($board,$row,$col);
        }
        $r_callback->();
    }
}

sub fill {
    my ($row,$slots) = @_;
    my $empty  = (11 - $slots)/2;
    for my $col (0 + $empty .. $empty + $slots - 1){
        $row->[$col] = 1;
    }
}

my $board;
push @$board, [(-1) x 11] for 1 .. 11;
fill($board->[2],3);
fill($board->[3],5);
fill($board->[4],7);
fill($board->[5],7);
fill($board->[6],7);
fill($board->[7],5);
fill($board->[8],3);


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
#    if($element == 0){
#        if($board->[$row[
#    }
}

#$board->[0][3] = 0;
#$board->[4][3] = 0;
#$board->[5][3] = 0;
traverse_board($board, $print_sub, sub {print "\n"});
#print Dumper($board);
