use strict;
use warnings;
use v5.10;

use Exporter 'import';
our @EXPORT = qw ( points_strat );

my $points_sub = sub {
    (my $board,my $row, my $col, my $points) = @_;
    my $element = $board->[$row][$col];
    if($element == 1){
        if($row == 0 || $row == 6 || $col == 0 || $col == 6){
            $$points += 1;
        }
        elsif(($row == 1 && $col == 1) ||
            ($row == 1 && $col == 5) ||
            ($row == 5 && $col == 1) ||
            ($row == 5 && $col == 5)){
            $$points +=5;
        }
    }
};
sub points_strat {
    (my $board,my $marbles,my $unsolv) = @_;
    my $points = 0;
    $board->traverse($points_sub, sub {},\$points);
    if($marbles < 15 && $points > 9){
        $$unsolv = 1;
    }
    elsif($marbles - $points < 0){
        $$unsolv = 1;
    }
}
