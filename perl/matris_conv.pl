#!/usr/bin/perl -w
#
# usage -v |-m [sumcol classificationcolumnnro numofclasses indexcolumns(esim 1-3)] delim datafile 
# -v: [datafileformat icd,sex,munic,year,a1-18
# Ohjelma muuntaa rinnakkain yhdelle riville merkityt tapaukset pötköksi lisäten oman 
# sarakkeen ikäryhmää osoittamaan]
# 
#-m: muuntaa sarakkeena olevan luokittelijan luokkasarakkeiksi vähentäen siis rivejä ja lisäämällä vastaavasti sarakkeita
#     esim: matris_conf.pl -m 4 5 18 0-2 '\t' Population.txt
#

use strict;

# valitaan päätoiminto
my $opt=shift(@ARGV);
my $fname=pop(@ARGV);
my $delim=pop(@ARGV);

if (!@ARGV){
	print "# usage -v |-m [sumcol classificationcolumnnro numofclasses indexcolumns(esim 1-3)] delim datafile \
 -v: [datafileformat icd,sex,munic,year,a1-18 \
 Ohjelma muuntaa rinnakkain yhdelle riville merkityt tapaukset pötköksi lisäten oman\ 
 sarakkeen ikäryhmää osoittamaan]\
 \
-m: muuntaa sarakkeena olevan luokittelijan luokkasarakkeiksi vähentäen siis rivejä ja lisäämällä vastaavasti sarakkeita\n\
     esim: matris_conf.pl -m 4 3 18 0-2 '\\t' Population.txt (year,sex,munic,agegroup,pop)\
     In addition adds TOTAL column to end of the row.\
\
VERSION 04072016, toni.patama\@gmail.com \n\    
";
}
elsif (-e $fname)
{

  if ($opt=~ /-v/)
  {
########################	
	open(KAHVA,$fname) or die $!;
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
			if($_>0)
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
##############################3
	}
	else
	{
	# tämä osa tekee aluksi niin, että tarvitaan ko luokk
		my @data=load_datafile($fname,$delim);
		my @newtable=();
		my @indexcols=split(/-/,pop(@ARGV));
		@indexcols=($indexcols[0]..$indexcols[1]);
		my $numofic=@indexcols;
		my $classes=pop(@ARGV);
		my $classcol=pop(@ARGV);
		my $sumcol=pop(@ARGV);
		
		#tehdään päädatasta versio johon indeksisarakkeet muodostavat vain yhden sarakkeen
		my $header=shift(@data);		
		my @idata=();
		foreach (@data)
		{
			my @rcols=@{$_};
			#my @icols=splice(@rcols,@indexcols);
			#poista icolsit rcolsista
			# ....
			
			my $istr=join("_",@rcols[@indexcols]);
			#@rcols=icols;
			my @newrow=();
			push @newrow,$istr;
			push @newrow,@rcols[($classcol,$sumcol)]; #komonterivin attribuutit vaikuttaa tÃ¤hÃ¤n
			push @idata,\@newrow;
		}
		# optimizing algrithm - sort idata
		@idata = sort { $a->[0] cmp $b->[0] } @idata;
		
		
		#tehdään ensiksi indeksilista, jonka perään sitten sosiaaliluokat ja niiden arvot tulevat vuorosarakkein
		# year,sex,munic ~ ilist
		my @ilist=group_by(@data,\@indexcols);
		@ilist = sort { "@{$a}" cmp "@{$b}" } @ilist;
		my $i=0;
		my $ti=0;
		foreach my $is(@ilist)
		{
			#etsitään kaikki ko indeksin tapaukset
			my $is2=join("_",@{$is});
			my @templist=();
			my $tf=0;
			for (my $r=$ti; $tf==0; $r++)
			{
				if($idata[$r][0] eq $is2){
					push @templist,$idata[$r];
					$ti++;
				}
				else {
					$tf=1;
				}
			}
			
			# my @templist=grep { $_->[0] eq $is2 } @idata;
			#käydään tapaukset läpi yksitellen ja lisätään totalsarakkeen arvoa aina ko sosiaaliluokan kohdalla johon ko idatan luokittelija viittaa

#			my @newrow=();
#			$newrow[0]=$is2;
#			foreach (@templist)
#			{
#				if ($newrow[$_->[1]])
#				{
#					my $val=$newrow[$_->[1]]+$_->[2];
#					$newrow[$_->[1]]=$val;
#				}
#				else
#				{
#					$newrow[$_->[1]]=$_->[2];
#				}
#			}
#			print join(";",@newrow),"\n";	

			$newtable[$i]=[zeros($classes+1)];
			$newtable[$i][0]=join(";",@{$is});
			
			foreach (@templist)
			{
				#onko solua (tietty ikäryhmä: $_->[1]) jo taulussa?
				if ($newtable[$i][$_->[1]] && $newtable[$i][$_->[1]] <= $classes)
				{
					my $val=$newtable[$i][$_->[1]] + $_->[2];
					$newtable[$i][$_->[1]]=$val;
				}
				elsif ($newtable[$i][$_->[1]] && $newtable[$i][$_->[1]] > $classes)
				{
					#my $colv=$classcol
					my $val=$newtable[$i][$classes] + $_->[2];
					$newtable[$i][$classes]=$val;
				}
				else
				{
					if($_->[1]>$classes){
						$newtable[$i][$classes]=$_->[2];
						}
					else {
						$newtable[$i][$_->[1]]=$_->[2];
						}
				}
			}
			$i++;
		}
		@idata=();
		@ilist=();

		foreach (@newtable)
		{
			my @rivi=();
			my $j=0;
			foreach my $alkio(@{$_})
			{
				if (!$alkio)
				{
					$alkio=0;
				}
				push @rivi,$alkio;
				$j++;
			}
			
			my $maxcol=$classes;
			if ($classes > $j)
			{
				while ($j<=$classes)
				{
					push @rivi,"0";
					$j++;
				}
			}
			# laskee totaalisarakkeen
			my $totss=0;
			map { $totss += $_ } @rivi[1..$classes];
			push @rivi,$totss;
			print join(";",@rivi) . "\n";				
		#		print "@{$_}\n";
		
		}

	}			
}
else
{
	print "File $fname not found!\n";
}

###################################################3
# 
# -poistaa tyhjät alusta
# -tallentaa solut viittauksin uuteen tauluun
#
sub load_datafile
{
	my $filename=shift(@_);
	my $delim=shift(@_);
	
	open(KAHVA,$filename) or die "ei onnistu\n";
	my @rivit=<KAHVA>;
	close KAHVA;
	my @ud=();
	foreach (@rivit)
	{
		chomp; #poistaa unix rivinvaihdon
	#	chomp;
		$_=~s/\r$//; #poistaa dos rivinvaihdon
		$_=~s/^ //; #poistaa alusta tyhjän merkin 	
	#	if ($_=~ /^[0-9]./)
	#	{
		my @row=split(/[ ;,\t]+/,$_);
		push @ud,\@row;
	#	}
	}
	return @ud;

}


#############3
# group by hakee datan halutuista sarakkeista kaikki eri kombinaatiot poistaen
# ne sarakkeet jotka eivät saatuun indeksimatriisiin kuulu.
sub group_by
{
	my @cols=@{pop(@_)};
	my @nd=();
	my @data=();
	foreach (@_)
	{
		my @nrow=@{$_}[@cols];
		my $dr=join("_",@nrow);
		push @nrow,$dr;
		push @data,\@nrow;
	}
#	for ($j=0;$j<=$#data;$j++)
	@data=sort { $a->[$#{$a}] cmp $b->[$#{$b}] } @data;
	my $cstr="";
	foreach (@data)
	{
		my @tr2=@{$_};
		my $mstr=$tr2[$#tr2];
		if ($cstr!~ /$mstr/)
		{
			#my @tr=split (/_/,$_);
			#$l=$
			my @tr=@tr2[0..($#tr2-1)];
			push @nd,\@tr;
			$cstr=$mstr;
		}	
	}

	return @nd;
}

sub zeros
{
	my $n=shift(@_);
	#my $v=0
	my @zlist=();
	for (my $i=0; $i<$n; $i++){
		push @zlist,0;
	}
	return @zlist;
}
