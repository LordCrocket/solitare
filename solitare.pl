#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use v5.10;
$| = 1;
my $pad = 2;
my $debug = 0;

{
    package Move;
    use strict;
    use warnings;
    use Clone 'clone';
    my $adj = $pad - 1;
    sub new {
        my ($class, %args) = @_;
        return bless { %args }, $class;
    }

    sub to_string {
        my $self = shift;
        my $start = "(" . ($self->{startRow} - $adj) . "," .  ($self->{startCol} - $adj) . ")";
        my $dest =  "(" . ($self->{destRow} - $adj) . "," . ($self->{destCol} - $adj) . ")";
        return "$start => $dest";

    }

    sub perform {
        my ($self,$board) = @_;
        my $newBoard = clone($board);
        my $interRow = ($self->{destRow} - $self->{startRow}) / 2;
        my $interCol = ($self->{destCol} - $self->{startCol})/ 2;
        $newBoard->[$self->{destRow}][$self->{destCol}] = 1;
        $newBoard->[$self->{startRow}][$self->{startCol}] = 0;
        $newBoard->[$self->{startRow}+$interRow][$self->{startCol} + $interCol] = 0;
        return $newBoard;

    }

    sub right {
        shift;
        my ($board,$row,$col) = @_;
        if($board->[$row][$col+1] == 1 && $board->[$row][$col+2] == 1){
            return Move->new(startRow => $row,
                             startCol => $col + 2,
                             destRow => $row,
                             destCol => $col);
        }
    }
    sub left {
        shift;
        my ($board,$row,$col) = @_;
        if($board->[$row][$col-1] == 1 && $board->[$row][$col-2] == 1){
            return Move->new(startRow => $row,
                             startCol => $col - 2,
                             destRow => $row,
                             destCol => $col);
        }
    }
    sub up {
        shift;
        my ($board,$row,$col) = @_;
        if($board->[$row-1][$col] == 1 && $board->[$row-2][$col] == 1){
            return Move->new(startRow => $row - 2,
                             startCol => $col,
                             destRow => $row,
                             destCol => $col);
         }
    }
    sub down {
        shift;
        my ($board,$row,$col) = @_;
        if($board->[$row+1][$col] == 1 && $board->[$row+2][$col] == 1){
        return Move->new(startRow => $row + 2,
                         startCol => $col,
                         destRow => $row,
                         destCol => $col);
        }
    }

}

sub traverse_board {
    (my $board, my $e_callback,my $r_callback,my $acc) = @_;
    for my $row (0+$pad .. 6+$pad){
        foreach my $col (0+$pad .. 6+$pad){
            $e_callback->($board,$row,$col,$acc);
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

my $orphans_sub = sub {
    (my $board,my $row, my $col,my $found) = @_;
    my $element = $board->[$row][$col];
    if($element == 1){
        if($board->[$row+1][$col] != 1 && $board->[$row+2][$col] != 1
        && $board->[$row-1][$col] != 1 && $board->[$row-2][$col] != 1
        && $board->[$row][$col+1] != 1 && $board->[$row][$col+2] != 1
        && $board->[$row][$col-1] != 1 && $board->[$row][$col-2] != 1){
            $$found = 1;
        }
    }

    if($$found == 1){
        #say "Unsolvable";
    }
};

sub print_board{
    (my $board) = @_;
    traverse_board($board, $print_sub, sub {print "\n"});
}
sub get_moves {
    (my $board) = @_;
    my $moves = [];
    traverse_board($board, $moves_sub, sub {},$moves);
    return $moves;
}

sub unsolvable {
    (my $board) = @_;
    my $found = 0;
    traverse_board($board, $orphans_sub, sub {},\$found);
    if($found){
        #print_board($board);
    }
    return $found;
};
sub  print_moves {
    (my $moves) = @_;
    foreach my $move (@{$moves}){
        say $move->to_string();
    }
}

sub solve {
    my ($board,$marbles,$target) = @_;
    state $unsolv = 0;
    state $out_of_moves = 0;

    if($marbles == $target){
        print_board($board);
        return 1;
    }
    if(unsolvable($board)){
        $unsolv++;
        return 0;         
    }

    foreach my $move (@{get_moves($board)}){
        if(solve($move->perform($board),$marbles-1,$target)){
            say $move->to_string();
            return 1;
        }
        elsif($debug) {
            if($out_of_moves % 10000 == 0 || $unsolv % 10000 == 0){
                say "OutOfMoves: $out_of_moves, unsolvable: $unsolv";
            }
        }
    }
    $out_of_moves++;
    return 0;
}

$board->[2][5] = 0;

$debug = 0;
# 36 marbles
solve($board,36,4);
