#!/bin/bash
# sample: bash mk_inc_runs.sh cases export_Nordic_pop_7113_INC.txt -ng 1971-1977:1974-1980:1977-1983:1980-1986:1983-1989:1986-1992:1989-1995:1992-1998:1995-2001:1998-2004:2001-2007:2004-2010:2007-2013 "sep=_:3:4" inc/nord15_inc > ajot.sh
# parameters
# $1 cases dir
# $2 poulation file
# $3 arguments i.e -ng
# $4 manual periods
# $5 cases pattern for cases ie: nord15_cases_340_1.csv --> sep=_:3:4 separator:cancertype:sex
# $6 incidence file prefix
####

# read case files to list

casefilename=`ls -1 $1`
casefilenamelist=( $casefilename )
#echo ${casefilenamelist[1]}
incprefix=$6
casefarg=(`echo $5 | awk 'BEGIN{FS=":"}{print substr($1,4) $2 $3}'`)

count=0
while [ -n "${casefilenamelist[count]}" ]
do
   cfn=${casefilenamelist[count]}
   # sep = _ xxx_yyy_234_0.csv -> "_234_0.csv"
   cinfo=(`echo $cfn | awk 'BEGIN{FS="_"}{print "_"$(NF-1)"_"$(NF)}'`)
   runstr="perl calc_inc_2015.pl $3 $4 $1/$cfn $2 > $6$cinfo"
   echo $runstr
   count=$(( $count + 1 ))
   #echo count
done
