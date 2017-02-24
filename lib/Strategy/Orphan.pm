use strict;
use warnings;
use v5.10;

use Exporter 'import';
our @EXPORT = qw ( orphans_strat );

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
sub orphans_strat {
    (my $board,my $unsolv) = @_;
    $board->traverse($orphans_sub, sub {},$unsolv);
}

