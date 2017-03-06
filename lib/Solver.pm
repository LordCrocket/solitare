package Solver;
use strict;
use warnings;
use v5.10;

use Memoize;
use DB_File;

use Math::BigInt;
use Move;
use Board;

use Data::Dumper;

sub new {
    my $class = shift;
    my $args =  shift;
    my $self = bless $args,$class;
    activate_memoize($self->{memoize},$self->{debug});
    return $self;
} 

sub _solve {
    my ($board,$marbles,$target,$strategies,$config) = @_;
    state $tries = 0;
    state $unsolv = 0;
    state $out_of_moves = 0;
    $tries++;
    if($config->{debug} && $tries % 10000 == 0) {
        say "Tries: $tries"; 
    }

    if($marbles == $target){
        $board->print() unless $config->{quiet};
        return 1;
    }

    #if($marbles == center_mass($board)){
    #    $board->print();
    #}
    if(_unsolvable($board,$marbles,$strategies,$config)){
        $unsolv++;
        if($config->{debug} && $unsolv % 10000 == 0) {
            say "Unsolvable: $unsolv";
        }
        return 0;
    }

    foreach my $move (@{_get_moves($board)}){
        if(_solve($move->perform($board),$marbles-1,$target,$strategies,$config)){
            say $move->to_string() unless $config->{quiet};
            return 1;
        }
        if($config->{debug}) {
            if(($out_of_moves != 0 && $out_of_moves % 10000 == 0) || ($unsolv != 0 && $unsolv % 10000 == 0)){
                say "OutOfMoves: $out_of_moves, unsolvable: $unsolv";
            }
        }
    }
    $out_of_moves++;
    return 0;
}
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
sub _get_moves {
    (my $board) = @_;
    my $moves = [];
    $board->traverse($moves_sub, sub {},$moves);
    return $moves;
}

sub _unsolvable {
    (my $board,my $marbles,my $strategies,my $config) = @_;
    my $unsolv = 0;
    foreach my $strategy (@$strategies){
        if($unsolv == 0){
            $strategy->($board,$marbles,\$unsolv);
        }
    }
    if($unsolv && $config->{debug} > 1){
        $board->print();
    }
    return $unsolv;
}
my $to_string_sub =  sub  {
    (my $board,my $row, my $col,my $string) = @_;
    my $element = $board->[$row][$col];
    
    $$string .= $element > 0 ? $element : 0;
};


sub board_to_string {
    (my $board) = @_;
    my $string = "";
    
    $board->traverse($to_string_sub, sub {},\$string);
    my $digit =  Math::BigInt->from_bin($string);
    return sprintf("%X", $digit);
}


sub activate_memoize {
    (my $memoize,my $debug) = @_;
    if(defined $memoize){
        my $cache_type = 'MEMORY';

        if($memoize){
            tie my %cache => 'DB_File', $memoize, O_RDWR|O_CREAT, 0666;
            $cache_type = [HASH => \%cache];
        }
        say "Using memoize. [$memoize]"  if $debug;
        memoize('_solve',NORMALIZER => 'board_to_string',SCALAR_CACHE => $cache_type);
    }
}
#sub print_moves {
#    (my $moves) = @_;
#    foreach my $move (@{$moves}){
#        say $move->to_string();
#    }
#}
#
my $number_of_marbles_sub = sub {
    (my $board,my $row, my $col,my $count) = @_;
    my $element = $board->[$row][$col];
    $$count += $element if $element > 0;
};


sub solve {
    my ($self,$board,$target,$strategies) = @_;
    my $marbles = 0;
    $board->traverse($number_of_marbles_sub, sub {},\$marbles);
    my $config = { debug => $self->{debug},
                   quiet  => $self->{quiet} };
    return _solve($board,$marbles,$target,$strategies,$config);
}
1;
