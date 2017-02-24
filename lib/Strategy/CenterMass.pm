use strict;
use warnings;
use v5.10;
#use Exporter 'import';
#our @EXPORT = qw ( orphans_strat );

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

