# bash mk_inc_runs.sh cases si_pop9814_for_inc.csv -ng 1998-2005:2003-2010:2007-2014 "sep=_:4:5" inc/sici_inc >ajo_meso.sh
perl calc_inc_2015.pl -ng 1998-2005:2003-2010:2007-2014 cases/cases_meso_0.csv si_pop9814_for_inc.csv > inc/sici_inc_meso_0.csv &
perl calc_inc_2015.pl -ng 1998-2005:2003-2010:2007-2014 cases/cases_meso_1.csv si_pop9814_for_inc.csv > inc/sici_inc_meso_1.csv

