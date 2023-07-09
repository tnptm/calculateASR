# import classes and functions
from calcAsr import Runsettings,DataLoad,start_main,calcASR
import sys
import pandas as pd


def runAsr(gender, popfile, casefile, periods=None, popstd='europe', agegroups='[1-18]', outputfn = "stdout" ):
    # load datas
    popdata = DataLoad("pop",popfile)
    popdata.execute()
    #casedata = DataLoad("case","C713.csv")
    casedata = DataLoad("case", casefile)
    try:
        casedata.execute()
    except Exception as error:
        print(error)
    res = None
    if len(casedata.data)==0 or len(popdata.data)==0:
        print("\nNoDataError: Exiting without calculation...")
        return None
    else:
        # gender = 1 (females)
        #outputfile = "incs/inc_" + casefile
        setting = Runsettings( gender, "Population_Ragusa_Caltanissetta.csv", casefile, popstd='europe', agegroups='1-18',outputfn="stdout")
        # define periods
        if periods:
            setting.generatePeriodsAuto( popdata.data, periods["plength"], periods["pstep"] )
            # run!
            res=calcASR( popdata, casedata, setting)
        else:
            print("Nothing to do - define periods")
        return res

casefile = sys.argv[-1]
gender = 1
periods = {
    "plength" : 5,
    "pstep" : 2
}

result = runAsr(gender, "Population_Ragusa_Caltanissetta.csv", casefile, periods, 'europe', '[1-18]')
#result = runAsr(gender, "Population_Ragusa_Caltanissetta.csv", casefile, periods, 'europe', '[1-18]', 'incs/incC713.csv')