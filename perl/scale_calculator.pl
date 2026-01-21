#!/usr/bin/perl -w
#
#
#use strict;
use CGI;
my $q=new CGI;
print $q->header('text/html');

print $q->start_html(
		-title=>'syöpäkartta',
		-author=>'toni.patama@gmail.com',
		-bgcolor=>"#feeeca");
print $q->h1('Scale settings calculator');
print "<p><hr><p>";

print $q->start_multipart_form(-method=>POST,
			-action=>"/cgi-bin/scale_calculator.pl");

print "<table>";
print "<tr><td>*Number of classes:</td><td>",$q->textfield(-name=>'classes',-value=>'');	
print "<tr><td>Minimum value:</td><td>",$q->textfield(-name=>'lmin',-value=>'');	
print "<tr><td>Maximum value:</td><td>",$q->textfield(-name=>'lmax',-value=>'');	
print "<tr><td>Ratio:</td><td>",$q->textfield(-name=>'ratio',-value=>'');
print "<tr><td>Median:</td><td>",$q->textfield(-name=>'median',-value=>'');

print "</table>";
print $q->submit(-name=>'solve', -value=>'SOLVE');

print $q->end_form,"<p>";


if ($q->param('solve'))
{
	print "<h3>Results</h3>";
	if ($q->param('lmin') && $q->param('lmax') && $q->param('classes'))
	{
		my $lmin=$q->param('lmin');
		my $lmax=$q->param('lmax');
		my $cl=$q->param('classes');

		my $ratio=solve_ratio($cl,$lmin,$lmax);	
		print "ratio: " . sprintf("%.4f",$ratio) . "<br>";
		my $expected=solve_median($lmin,$ratio,$cl);
		print "median: " . sprintf("%.4f",$expected) . "<br>";
	}
	elsif ($q->param('lmin') && $q->param('ratio') && $q->param('classes'))
	{
		my $lmin=$q->param('lmin');
		my $ratio=$q->param('ratio');
		my $cl=$q->param('classes');

		my $expected=solve_median($lmin,$ratio,$cl);
		print "median: " . sprintf("%.4f",$expected) . "<br>";
		my $lmax=$expected*($ratio**(($cl/2)-1));	
		print "max: " . sprintf("%.4f",$lmax) . "<br>";

	}	
	elsif ($q->param('lmax') && $q->param('ratio') && $q->param('classes'))
	{
		my $lmax=$q->param('lmax');
		my $ratio=$q->param('ratio');
		my $cl=$q->param('classes');

		my $expected=solve_m2($lmax,$ratio,(($cl/2)-1));
		print "median: " . sprintf("%.4f",$expected) . "<br>";
		my $lmin=$expected*($ratio**((-$cl/2)+1));	
		print "min: " . sprintf("%.4f",$lmin) . "<br>";


	}
	elsif ($q->param('median') && $q->param('ratio') && $q->param('classes'))
	{
		my $median=$q->param('median');
		my $ratio=$q->param('ratio');
		my $cl=$q->param('classes');

		my $lmax=$median*($ratio**(($cl/2)-1));	
		print "max: " . sprintf("%.4f",$lmax) . "<br>";
		my $lmin=$median*($ratio**((-$cl/2)+1));	
		#my $expected=solve_median($lmin,$ratio,$cl);
		print "min: " . sprintf("%.4f",$lmin) . "<br>";
	}
	else
	{
		print "Check the given values again!";
	}	
		
	#		);
}
print $q->end_html();
	
# classes,lmin,lmax	
sub solve_ratio
{
	my $cl=shift(@_);
	my $lmin=shift(@_);
	my $lmax=shift(@_);
	my $ratio=10**(log10($lmax/$lmin)/($cl-2));
	return $ratio;
}

# kymmenkantainen logaritmi
sub log10 {
    my $n = shift;
    return log($n)/log(10);
}

# $lmin*$ratio^(($cl-2)/2)
sub solve_median
{
	my $lmin=shift(@_);
	my $ratio=shift(@_);
	my $cl=shift(@_);
	my $expected=$lmin*($ratio**(($cl-2)/2));
	return $expected;
}

sub solve_m2
{
	my $lim=shift(@_);
	my $ratio=shift(@_);
	my $cl_i=shift(@_); # input: lim=m*r^(cl_i)=> m=lim/r...
	my $m=$lim/($ratio**($cl_i));
	return $m;

}
