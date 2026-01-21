#!/usr/bin/perl -w
# 1.11.2008 laskee insidenssit -> print_usage() 
# 23.11.2009 versio lis‰‰ mahdollisuuden asettaa custom-periodit formaatissa: y1-y3:y2-y4:....
# 13.05.2010 mahdollisuus lis‰t‰ koko kuntalista, jotta myˆs zero-kunnat on tulostiedostossa
# 20.09.2010 etsii v√§est√∂datasta kunnat itse
# 11.11.2010 pari pienemp√§√§ bugia(kun on ainoastaan yksi ik√§luokka tai kun on yksi customperiod)
# 26.02.2011 -x -> -e syntax error
# 4.8.2011 kuntalistoihin uusi ominaisuus, jotta monen maan kunnat mahdollista lis‰t‰ kerralla csvheader: cntryid,municid
# 6.2.2012 more informative file error "ei onnistu"
# 5.11.2014 optimize the calculation
# 09/15 v2.4 cntryid ja kuntaid from population data (-ng) fix!!!
# 09.09.2015 v2.41 pop colfind optimize in loop
# 09.09.2015 v2.42 colfind optimize: if out from foreach
# 10.09.2015 v2.5 bug fixes (optimizing about 10 times!!!!)
############################################################################

use strict;

my $opt1=shift(@ARGV);
my $opt2;
my $runtype;
my $municfn;
my @cols=();
if ($opt1 && $opt1 =~ /-n$/)
{
	$runtype=0;
	@cols=(0,2,4);
	if ($ARGV[0]=~ /[\:-]/)
	{
		#custom periods
		$opt2=shift(@ARGV);
	}
}
# municipal file using preparing
elsif ($opt1 && $opt1 =~ /-ng=/)
{
	$runtype=2;
	@cols=(0,2,4);
	if ($ARGV[0]=~ /[\:-]/)
	{
		#custom periods
		$opt2=shift(@ARGV);
	}
	$municfn=$opt1;
	$municfn=~ s/.*=//;
	if (! -e $municfn)
	{
		$runtype="err";
		print "ERROR: Municipal list file $municfn doesn't exist or cannot be loaded.";
	}
}
# finds muncipalities from pop-data
elsif ($opt1 && $opt1 =~ /-ng/)
{
	$runtype=2;
	@cols=(0,2,4);
	if ($ARGV[0]=~ /[\:-]/)
	{
		#custom periods
		$opt2=shift(@ARGV);
	}
	$municfn=-1;
	#$municfn=~ s/.*=//;
	#if (! -x $municfn)
	#{
	#	$runtype="err";
	#	print "ERROR: Municipal list file $municfn doesn't exist or cannot be loaded.";
	#}
}


elsif ($opt1 && $opt1=~ /-m/)
{
	$runtype=1;
	@cols=(0,2);

}

else
{
	$runtype="err";
}


##GLOBALS
my $step;
my $pl;
if (!$opt2)
{
	$pl=shift (@ARGV);
# step 5 years and overlapping 5 years > whole period=10 years
	$step=shift (@ARGV);

}
# World standard
my @wstd=(0.12,0.1,0.09,0.09,0.08,0.08,0.06,0.06,0.06,0.06,0.05,0.04,0.04,0.03,0.02,0.01,0.005,0.005);



if (!@ARGV or $#ARGV<1 or $runtype=~ /err/)
{
		print_usage();
}
else
{



#######
# cases format: cntry,year,sex,agegroup,munic,total
#

my @cases=load_datafile($ARGV[0]);
my @pop=load_datafile($ARGV[1]);

my @municidlist=();
if ($runtype==2 && $municfn && -e $municfn)
{
	@municidlist=load_datafile($municfn);
	
}
elsif ($runtype==2 && $municfn==-1)
{
	@municidlist=find_munic_list(@pop);
}
#if ( $#{$municidlist[0]}==1)
#{
	# k‰ytet‰‰n muuttujaa cntryid, joilloin monta maata voidaan k‰ytt‰‰ samanaikaisesti


my @selages=();
my @cwstd=();
my $customageg=0;

if ($ARGV[2])
{
	#undefined value error fixed 10112010: if only one ageclass is selected
	if ($ARGV[2]=~ /-/)
	{
		@selages=split(/-/,$ARGV[2]); 
		@selages=($selages[0]..$selages[1]);
	}
	else
	{	
		$selages[0]=$ARGV[2];
	}
		
	my @selainds=map {$_-1} @selages;
	my @selstds=@wstd[@selainds];
	my $sumstds=0;
	foreach (@selstds)
	{
		$sumstds+=$_;	
	}
	foreach (@selstds)
	{
		my $sv= $_/$sumstds;
		push @cwstd, $sv;
	}
	$customageg=1;
}

my $np; #periodien lukum‰‰r‰
#laskee casedatasta minimi ja maksimi vuodet
my @min2max=sort {$a->[1] <=> $b->[1]} @cases;
my $ymin=$min2max[0][1];
my $ymax=$min2max[$#min2max][1]; 
my $y=$ymin; #aloitusvuosi


# sis periodi raja vuodet. viimeinen periodi alkaa @yv($#yv-2) ja p‰‰ttyy pop(@yv)
my @yv=();

if ($opt2)
{
	my @periods=split(/\:/,$opt2);
	#my @alkuloppuv=();
	foreach my $yperiod(@periods)
	{
		my @allo=split(/-/,$yperiod); # alku- ja loppuvuosi
		push @yv,\@allo;  #lis‰t‰‰n edelliset yhteen tauluun
	}
	$np=$#periods;
}
else
{


#push @yv,$y;
	while ($y<=($ymax-$pl+1))
	{
		push @yv,$y;
		$y+=$step;
	}
#periodien lukum‰‰r‰
	$np=$#yv; ##pit‰‰ olla -1 mutta kokeeksi -2 
}

my @inci_r=();
my @hdrs=();
my $startt=time;
for (0..$np)
{
	my $g=$_;
	my ($sy,$ey,$h_str);
	if ($opt2)
	{
		$sy=$yv[$g][0];
		$ey=$yv[$g][1];
	}
	else
	{
		$sy=$yv[$g];
		$ey=$yv[$g]+$pl-1;
	}
	
	$h_str=$sy . "-" . $ey;

	push @hdrs,$h_str;
	#print "$g:$sy-$ey\n";
	#select cancerdata for period
	my @pcdata=grep {$_->[1]>=$sy && $_->[1]<=$ey} @cases;

# optimoidaan popdatan hakuja rajaamalla data vuosiin
	#my @pop_by_period=colfind(\@pop,\@popcols,$r,'$_->[1]>=' . $sy . ' && $_->[1]<=' . $ey);
	my @pop_by_period=grep {$_->[1]>=$sy && $_->[1]<=$ey} @pop;
	
	#gpcd on indeksi paikasta ja sukupuolesta
	my @gpcd=group_by(@pcdata,\@cols);
	my @cancerpd=();

	# tehd‰‰n syˆp‰data, jossa on periodin vuodet yhdistetty ja caset laskettu yhteen
	my @popcols=(0,2,$#{$pop[0]});
	if ($runtype==1)
	{
		@popcols=(0,2);
	}
	my @acols=(3..20);
	if ($customageg==1)
	{
		@acols=map {$_+2} @selages;
		#@wstd=@cwstd;
	}
#	my $timetest=;
	
	# cntryid,municid,sex loop
	foreach my $r(@gpcd)
	{
		#my @mstrs=();
		
		#k‰sitell‰‰n kunkin paikan eri ik‰ryhm‰t erikseen
		
		#my @popmvals=@{$r};
		#vieko seuraavat rivit tarpeettoman paljon aikaa?
#		my @canc_byplace=colfind(\@pcdata,\@cols,\@popmvals);
#		my @pops=colfind(\@pop,\@popcols,\@popmvals,'$_->[1]>=' . $sy . ' && $_->[1]<=' . $ey);
		my @canc_byplace=colfind(\@pcdata,\@cols,$r);
#		my @pops=colfind(\@pop,\@popcols,$r,'$_->[1]>=' . $sy . ' && $_->[1]<=' . $ey);
		my @pops=colfind(\@pop_by_period,\@popcols,$r);
				
#		if (@pops && $timetest)
		if (@pops)
		{
			my @sumpop=summa(\@pops,@acols);
			my $incvalue=0;
		
			my $i=0;
			my @ccols=(3); # cancerdata: agegroup column
			# This loop goes thrue all the agegroups summing possible subincidences together
			foreach my $m(@acols)
			{
				
				my @mv=($m-2);
				my @tots=colfind(\@canc_byplace,\@ccols,\@mv);
	#			my @tots=grep {$_->[3]==$m} @canc_byplace;
				#print $#tots;
				if (@tots && $sumpop[$i]>0)
				{
					my @sumoverp=summa(\@tots,5);
					# N‰in ei pit‰is tapahtua jos jossain ik‰ryhm‰ss‰ on syˆp‰tapauksia, koska myˆs v‰estˆ‰ pit‰isi silloin olla
					if ($customageg==1)
					{
						$incvalue+=sprintf("%.4f",$sumoverp[0]*100000*$cwstd[$i]/$sumpop[$i]);
					}
					else
					{
						$incvalue+=sprintf("%.4f",$sumoverp[0]*100000*$wstd[$i]/$sumpop[$i]);
					}
				}
			#push @inc_byplace,$incvalue;
				$i++;
			}
			my @row=(join("_",@{$r}),$incvalue);
		#print "@row\n";
		
			push @cancerpd,\@row;
			}
	#	$i++;
#		print $#tots+1 . "," . "@mvalues" . "\n";
		}
		push @inci_r,\@cancerpd;
	
	}

#print $#inci_r;

# etsit‰‰n kaikki k‰ytetyt indeksit 

my @indexl=();
foreach my $period(@inci_r)
{
	foreach my $pv(@{$period})
	{
		#my $str=$pv->[0];
		my @f=grep {$_ eq $pv->[0]} @indexl;
		if ($#f==-1)
		{
			push @indexl,$pv->[0];
		}
	
	}
}

### tulosta header
if ($runtype==0 || $runtype==2)
{
	print "cntryid,municid,sex," . join(",",@hdrs) . "\n";
}
else
{
	print "cntryid,sex," . join(",",@hdrs) . "\n";
}

### data
my $sex;
my $cntryid;
my @municlist_def=();
my $j=0;
foreach my $mstr(@indexl)
{
	my @outrow=($mstr);
	foreach (@inci_r)
	{
		my @f=grep {$_->[0] eq $mstr} @{$_};
		my $ival=0;
		if (@f)
		{
			$ival=$f[0][1];
		}
		
		push @outrow,$ival;
	}
	my @ind=split(/_/,$outrow[0]);
	my @formatcols=(0,2,1);
	if($runtype==1)
	{
		@formatcols=(0,1);
	}
	@ind=@ind[@formatcols];
	if ($j==1)
	{
		$sex=$ind[2];
		$cntryid=$ind[0];
	}
	push @municlist_def,[@ind[(0,1)]];
	$outrow[0]=join(",",@ind);
	print join(",",@outrow) . "\n";
	$j++;
}

# check the municpalities

if($runtype==2)
{
	my $ccode=$cntryid;
	foreach my $ar(@municidlist)
	{
	#	my $ccode=
		my $mcode;
		my $c=0;
		if ($ar->[1])
		{
			$mcode=$ar->[1];
			$ccode=$ar->[0];
			$c=1;
		}
		else
		{
			$mcode=$ar->[0];
			#$ccode=$cntryid;
		}
		my $found=0; 
		foreach my $ar2(@municlist_def)
		{
			my $m_code_t=$ar2->[1];
			my $c_code_t=$ar2->[0];
			
			if ($c==1 && $mcode eq $m_code_t && $ccode eq $c_code_t)
			{
				$found=1;
				last;
			}
			elsif ($c==0 && $mcode eq $m_code_t)
			{
				$found=1;
				last;
			}
	
		}
		if ($found==0)
		{
			my @outrow=($ccode,$mcode,$sex);
			for (0...$np)
			{
				push @outrow, 0;
			}
			print join(",",@outrow). "\n";
		}
	}
}
#my $dur=time-$startt;
#print "Execution time: $dur s\n";

}


###################################################
# colfind(\@data,\@cols,[@values],$xtrarule)
sub colfind
{
	my @data=@{shift(@_)};
	my @cols=@{shift(@_)};
	my @vals=@{shift(@_)};
	my $xtrarule=shift(@_);
	
	# @vals
	my $mstr=join("_",@vals);
	
	my @nd=();
#	my @data=();
	# if clause out from loop...optimize
	if (! $xtrarule)
	{
		foreach (@data)
		{
			my $nrowstr=join("_",@{$_}[@cols]);
		#	if ($nrowstr=~/^$mstr$/)
			if ($nrowstr eq $mstr)			
			{
				push @nd,$_;
			}
		}
	}
	elsif ( $xtrarule && eval($xtrarule))
	{
		foreach (@data)
		{
		#my @nrow=@{$_}[@cols];
			my $nrowstr=join("_",@{$_}[@cols]);
		#	if ($nrowstr=~/^$mstr$/)
			if ($nrowstr eq $mstr)
			{
				push @nd,$_;
			}
		}
	}
	
	return @nd;

}

#############
# group by hakee datan halutuista sarakkeista kaikki eri kombinaatiot poistaen
# ne sarakkeet jotka eiv‰t saatuun indeksimatriisiin kuulu.
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
	my @cols_tr=(0..($#{$data[0]}-1));
	foreach (@data)
	{
		my @tr2=@{$_};
		my $mstr=$tr2[$#tr2];
		if ($cstr!~ /$mstr/)
		{
			#my @tr=split (/_/,$_);
			#$l=$
			my @tr=@tr2[@cols_tr];
#			my @tr=@tr2[0..($#tr2-1)];
			push @nd,\@tr;
			$cstr=$mstr;
		}	
	}

	return @nd;
}

##################################
# summa(\data,cols)
sub summa
{
	my @data=@{shift(@_)};
	my @cols=@_;
	my @r1=@{shift(@data)};
	my @sumr=@r1[@cols];
#		();
#	my $i=0;	
	foreach my $rivi(@data)
	{
		my @dcols=@{$rivi}[@cols];
		my $j=0;
		foreach (@dcols)
		{
			$sumr[$j]+=$_; # vrt ennen $sumr[$j]=$sumr[$j]+$_;
			$j++;
		}
	}
	return @sumr;

}





###################################################3
# -poistaa mahdollisen teksti otsikon
# -poistaa tyhj‰t alusta
# -tallentaa solut viittauksin uuteen tauluun
#
sub load_datafile
{
	my $filename=shift(@_);
	
	open(KAHVA,$filename) or die "ei onnistu: $filename -> $!\n";
	my @rivit=<KAHVA>;
	close KAHVA;
	my @ud=();
	foreach (@rivit)
	{
		chomp; #poistaa unix rivinvaihdon
	#	chomp;
#		$_=~s/\n$//;
		$_=~s/\r$//; #poistaa dos rivinvaihdon
		$_=~s/^ //; #poistaa alusta tyhj‰n merkin 	
		if ($_=~ /^[0-9].{0,}/)
		{
			my @row=split(/[ ;,\t]+/,$_);
			push @ud,\@row;
		}
	}
	return @ud;

}

sub print_usage
{
	print "\nUSAGE:\n calc_inc.pl [-n[g[=filename]]|-m] [custom periods|periodlength step] case_file population_file [agegroups: 3-8]\n\n";
	print "-n : \"run software normaly\"\n";
	print "-ng[=filename]  : \" uses whole municipal code list (file or from population) to generate zero-rows if needed.\"\n";
	print "-m : \"run software without using municipal codes\"\n\n";
	print "CASES data filestructure: country_id, year, sex, agegroup, municipalcode, total.\n";
	print "POPULATION: country_id, year, sex, agegroups1..N, total, municipalcode.\n\n";
	print "Toni Patama 10.09.2015 v 2.5\n";
}
	
# etsit‰‰n kuntalista v‰estˆdatasta
sub	find_munic_list
{
	my @pdata=@_;
	my @mun_col=();
#	map {push @mun_col,$_->[$#]} @pdata;
	#groub by
	@mun_col=group_by(@pdata,[0,$#{$pdata[0]}]);
	#my @cntryid_col=group_by(@pdata,[$#{$pdata[0]}]);
	return @mun_col;
}

	
