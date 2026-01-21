#!/usr/bin/perl -w
#
# usage p delim datafile
# datafileformat icd,sex,munic,year,a1-18
# Ohjelma muuntaa rinnakkain yhdelle riville merkityt tapaukset pötköksi lisäten oman 
# sarakkeen ikäryhmää osoittamaan
# 
use strict;
my $delim=shift(@ARGV);
open(KAHVA,$ARGV[0]) or die $!;
my $nrow=0;
while (<KAHVA>)
{
	$nrow++;
	if ($nrow>=1)
	{
		chomp;
		my @row=split(/$delim/,$_);
		my @ags=@row[4..21];
		my $i=0; #i kuvaa kuinkamones ikäryhmä on kysymyksessä
		
		foreach (@ags)
		{
			my @newr=@row[0..3];
			if($_ && $_>0)
			{
				#my @newr2=@newr;
				push @newr,($i+1);
				push @newr,$_;
				my $rivi=join($delim,@newr);
				print $rivi,"\n";
				
			}
			$i++;
		}
	}
	else
	{print $_;}
}
