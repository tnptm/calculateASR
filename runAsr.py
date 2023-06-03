from calcAsr import Runsettings,DataLoad,start_main,calcASR

popdata = DataLoad("pop","Population_Ragusa_Caltanissetta.csv")
casedata = DataLoad("case","C713.csv")
setting = Runsettings(1,"Population_Ragusa_Caltanissetta.csv","C713.csv")
setting.generatePeriodsAuto(popdata.data,5,2)
res=calcASR(popdata,casedata,setting)