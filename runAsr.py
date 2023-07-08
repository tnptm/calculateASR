# import classes and functions
from calcAsr import Runsettings,DataLoad,start_main,calcASR

# load datas
popdata = DataLoad("pop","Population_Ragusa_Caltanissetta.csv")
casedata = DataLoad("case","C713.csv")
# gender = 1 (females)
setting = Runsettings(1,"Population_Ragusa_Caltanissetta.csv","C713.csv",popstd='europe',agegroups='1-18')
# define periods
setting.generatePeriodsAuto(popdata.data,5,2)
# run!
res=calcASR(popdata,casedata,setting)