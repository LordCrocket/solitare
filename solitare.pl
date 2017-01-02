#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use v5.10;
$| = 1;
my $pad = 2;

{
    package Move;
    use strict;
    use warnings;
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
        my $interRow = ($self->{destRow} - $self->{startRow}) / 2;
        my $interCol = ($self->{destCol} - $self->{startCol})/ 2;
        $board->[$self->{destRow}][$self->{destCol}] = 1;
        $board->[$self->{startRow}][$self->{startCol}] = 0;
        $board->[$self->{startRow}+$interRow][$self->{startCol} + $interCol] = 0;

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

my $get_moves = sub {
    (my $board,my $row, my $col,my $moves) = @_;
    my $element = $board->[$row][$col];
    if($element == 0){
             
            push @$moves, grep {$_} (Move->right($board,$row,$col),
                                     Move->left($board,$row,$col),
                                     Move->up($board,$row,$col),
                                     Move->down($board,$row,$col));
    }
};

$board->[3][5] = 0;
#$board->[4][3] = 0;
#$board->[5][3] = 0;
my $moves = [];
traverse_board($board, $get_moves, sub {},$moves);
traverse_board($board, $print_sub, sub {print "\n"});
foreach my $move (@{$moves}){
    say $move->to_string();
}
$moves->[0]->perform($board);
traverse_board($board, $print_sub, sub {print "\n"});
#print Dumper($board);
