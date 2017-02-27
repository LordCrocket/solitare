package Board;
use strict;
use warnings;
use v5.10;

sub fill {
    my ($row,$slots) = @_;
    my $empty  = (7 - $slots)/2;
    for my $col (0 + $empty .. $empty + $slots - 1){
        $row->[$col] = 1;
    }
}

sub create_board {
	my $class = shift;
    my $board;
    push @$board, [(-1) x 7] for 1 .. 7;
    fill($board->[0],3);
    fill($board->[1],5);
    fill($board->[2],7);
    fill($board->[3],7);
    fill($board->[4],7);
    fill($board->[5],5);
    fill($board->[6],3);
	return bless $board, $class;
}

sub traverse {
    (my $self, my $e_callback,my $r_callback,my $acc) = @_;
    for my $row (0 .. 6 ){
        foreach my $col (0 .. 6){
            $e_callback->($self,$row,$col,$acc);
        }
        $r_callback->();
    }
}

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

sub print{
    (my $self) = @_;
    $self->traverse($print_sub, sub {print "\n"});
}

1;
