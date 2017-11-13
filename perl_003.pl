#!/usr/bin/perl

$jeden = shift;
$dwa = shift;
if ($jeden > $dwa) {
	my $tmp = $dwa;
	$dwa = $jeden;
	$jeden = $tmp;
}
$jeden--;
$dwa--;
print "$jeden $dwa\n";
#walidacja biorę arg 1, 2 jako numery
#walidacja następnych args jako plików tekstowych
#to co mogę przetwarzam
#

while(<>) {
# usuwam wszystkie informacje z words bo jeżeli rozmiar będzie mniejszy w następnej linijce to zostnie
	undef @words;
	@words = split;
	if (scalar @words > $dwa) {
		print join(' ', @words[$jeden .. $dwa]);
	}
	print "\n";
	#co to chop?
	#co to chomp?
	#print STDOUT "Welcome to our little program\n";
	#print STDERR "Could not open file\n";
}

