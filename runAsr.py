# import classes and functions
from calcAsr import Runsettings,DataLoad,start_main,calcASR
import sys
import pandas as pd


def runAsr(gender, popfile, casefile, outputfn, periods=None, popstd='europe', agegroups='[1-18]' ):
    """
        Loading datas and settings
        
        runAsr( gender, population-filename, cases-filename, output-filename, predefined-periods, population-standard:'europe'|'world', age-groups)
        
        Function runAsr is helper interface for the main function calcASR. It loads datas and defines
        settings to be able to calculate and return meaningful results
    """
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
        setting = Runsettings( gender, popfile, casefile, outputfn, popstd='europe', agegroups='1-18')
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

#result = runAsr(gender, "population.csv", casefile, "stdout", periods, 'europe', '[1-18]')
result = runAsr(gender, "population.csv", casefile, 'incs/incC713.csv', periods, 'europe', '[1-18]')
