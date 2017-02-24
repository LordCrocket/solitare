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
use Solver qw(solve activate_memoize);

$| = 1;
my $debug = 0;
my $marbles = 4;
my $memoize;

GetOptions ('v+' => \$debug,'m:s' => \$memoize,'n:i' => \$marbles );

my $board = Board->create_board();


my $orphans_sub = sub {
    (my $board,my $row, my $col,my $unsolv) = @_;
    if($$unsolv == 1){
        return;
    }
    my $element = $board->[$row][$col];
    if($element == 1){
        my $startRow = $row - 2;
        my $endRow = $startRow + 4;

        my $startCol = $col - 2;
        my $endCol = $startCol + 4;

        $startRow = $startRow > 0 ? $startRow : 0;
        $startCol = $startCol > 0 ? $startCol : 0;

        $endRow = $endRow < 7 ? $endRow : 6;
        $endCol = $endCol < 7 ? $endCol : 6;
        for my $nRow ($startRow .. $endRow){
            foreach my $nCol ($startCol .. $endCol){
                next if($nRow == $row && $nCol == $col);
                if($board->[$nRow][$nCol]>0){
                    $$unsolv = 0;
                    return;
                }
            }
        }
        $$unsolv = 1;
    }

};
my $orphans_strat = sub {
    (my $board,my $unsolv) = @_;
    $board->traverse($orphans_sub, sub {},$unsolv);
};

sub _center_mass {
    (my $board) = @_;
    my $mass = 0;
    for my $row ( 1 .. 5 ){
        foreach my $col (1 .. 5){
            if(!(($col == 1 && $row == 1)
                || ($col == 1  && $row == 5)
                || ($col == 5  && $row == 1)
                || ($col == 5  && $row == 5))){
                my $element = $board->[$row][$col];
                $mass += $element;
            }
        }
    }
    return $mass;
}

sub center_mass {
    (my $board,my $size) = @_;
    $size //= 25;
    $size = $size > 25 ? 25 : $size;
    my $mass = 0;
    my $row =  3;
    my $col =  3;
    my @moves = ([0,1],[-1,0],[0,-1],[1,0]);
    my $turn = 0;
    my $times = 1;
    my $step = 1;
    my $element = $board->[$row][$col];
    $mass += $element;
    $size--;
    while(1){

        for(1 .. $step){
            if($size < 1){
                return $mass;
            }
            $row += $moves[$turn]->[0]; 
            $col += $moves[$turn]->[1]; 
            my $element = $board->[$row][$col];
            $mass += $element;
            $size--;
        }

        $turn++;
        $turn = $turn%4;

        if($times % 2 == 0){
            $step++;
            $times = 0;
        }
        $times++;

    } 
}



$board->[0][3] = 0;
# 36 marbles
my $strategies = [$orphans_strat];
my $solver = Solver->new({debug => $debug,memoize => $memoize});
$solver->solve($board,36,$marbles,$strategies);
