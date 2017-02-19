#!/usr/bin/perl

use strict;
use warnings;
use v5.10;

use FindBin;
use local::lib "$FindBin::Bin/perl5";
use lib "$FindBin::Bin/lib";

use Data::Dumper;
use Memoize;
use DB_File;
use Math::BigInt;
use Getopt::Long;

## Custom ##
use Move;
use Board;


$| = 1;
my $debug = 0;
my $marbles = 4;
my $memoize;

GetOptions ('v+' => \$debug,'m:s' => \$memoize,'n:i' => \$marbles );

my $board = Board->create_board();

my $moves_sub = sub {
    (my $board,my $row, my $col,my $moves) = @_;
    my $element = $board->[$row][$col];
    if($element == 0){
             
            push @$moves, grep {$_} (Move->right($board,$row,$col),
                                     Move->left($board,$row,$col),
                                     Move->up($board,$row,$col),
                                     Move->down($board,$row,$col));
    }
};

my $to_string_sub =  sub  {
    (my $board,my $row, my $col,my $string) = @_;
    my $element = $board->[$row][$col];
    
    $$string .= $element > 0 ? $element : 0;
};

my $orphans_sub = sub {
    (my $board,my $row, my $col,my $unsolv) = @_;
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

sub board_to_string {
    (my $board) = @_;
    my $string = "";
    
    $board->traverse($to_string_sub, sub {},\$string);
    my $digit =  Math::BigInt->from_bin($string);
    return sprintf("%X", $digit);

}
sub get_moves {
    (my $board) = @_;
    my $moves = [];
    $board->traverse($moves_sub, sub {},$moves);
    return $moves;
}

sub unsolvable {
    (my $board) = @_;
    my $unsolv = 0;
    $board->traverse($orphans_sub, sub {},\$unsolv);
    if($unsolv){
        #print_board($board);
    }
    return $unsolv;
}
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



sub  print_moves {
    (my $moves) = @_;
    foreach my $move (@{$moves}){
        say $move->to_string();
    }
}

sub solve {
    my ($board,$marbles,$target) = @_;
    state $tries = 0;
    state $unsolv = 0;
    #state $out_of_moves = 0;
    $tries++;
    if($debug && $tries % 10000 == 0) {
        say "Tries: $tries"; 
    }

    if($marbles == $target){
        $board->print();
        return 1;
    }

    if($marbles == center_mass($board)){
        $board->print();
    }
    #if(($marbles < 22 && (center_mass($board,$marbles+8) < ($marbles - sqrt($marbles) + 1)))){
    #    $unsolv++;
    #    if($debug && $unsolv % 10000 == 0) {
    #        say "Not centered: $unsolv"; 
    #    }
    #    return 0;         
    #}

    foreach my $move (@{get_moves($board)}){
        if(solve($move->perform($board),$marbles-1,$target)){
            say $move->to_string();
            return 1;
        }
        #if($debug) {
        #    if(($out_of_moves != 0 && $out_of_moves % 10000 == 0) || ($unsolv != 0 && $unsolv % 10000 == 0)){
        #        say "OutOfMoves: $out_of_moves, unsolvable: $unsolv";
        #    }
        #}
    }
    #$out_of_moves++;
    return 0;
}


$board->[0][3] = 0;
if(defined $memoize){
	my $cache_type = 'MEMORY';
	
	if($memoize){
		tie my %cache => 'DB_File', $memoize, O_RDWR|O_CREAT, 0666;
		$cache_type = [HASH => \%cache];
	}
	say "Using memoize. [$memoize]" if $debug;
	memoize('solve',NORMALIZER => 'board_to_string',SCALAR_CACHE => $cache_type);
}
# 36 marbles
solve($board,36,$marbles);
