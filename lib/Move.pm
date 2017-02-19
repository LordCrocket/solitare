package Move;
use strict;
use warnings;
use Clone 'clone';

my $adj = -1;

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
	if($col < 5 && $board->[$row][$col+1] == 1 && $board->[$row][$col+2] == 1){
		return Move->new(startRow => $row,
				startCol => $col + 2,
				destRow => $row,
				destCol => $col);
	}
}
sub left {
	shift;
	my ($board,$row,$col) = @_;
	if($col > 1 && $board->[$row][$col-1] == 1 && $board->[$row][$col-2] == 1){
		return Move->new(startRow => $row,
				startCol => $col - 2,
				destRow => $row,
				destCol => $col);
	}
}
sub up {
	shift;
	my ($board,$row,$col) = @_;
	if($row > 1 && $board->[$row-1][$col] == 1 && $board->[$row-2][$col] == 1){
		return Move->new(startRow => $row - 2,
				startCol => $col,
				destRow => $row,
				destCol => $col);
	}
}
sub down {
	shift;
	my ($board,$row,$col) = @_;
	if($row < 5 && $board->[$row+1][$col] == 1 && $board->[$row+2][$col] == 1){
		return Move->new(startRow => $row + 2,
				startCol => $col,
				destRow => $row,
				destCol => $col);
	}
}

1;
