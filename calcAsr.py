import numpy as np
import pandas as pd
import sys
import os.path

#print(sys.argv)

def Version():
    return "b0.3/07072023 toni.patama@gmail.com"
    #30042023 toni.patama@gmail.com"

class Predefs:
    age_stds = pd.DataFrame({
        'agegroup_index' : list(range(1,19)),
        'world' : [ 0.12, .10, .09, .09, .08, .08, .06, .06, .06, .06, .05, .04, .04, .03, .02, .01, .005, .005 ],
        'europe' : [ .08, .07, .07, .07, .07, .07, .07, .07, .07, .07, .07, .06, .05, .04, .03, .02, .01, .01 ]
        })
    agegroupdef = {
        "0-4": 1,"5-9": 2,"10-14": 3,"15-19": 4,"20-24": 5,"25-29": 6,"30-34": 7,"35-39": 8,"40-44": 9,
        "45-49": 10,"50-54": 11,"55-59": 12,"60-64": 13,"65-69": 14,"70-74": 15,"75-79": 16,"80-84": 17, "85+":18,
    }
    data_hdr_info = {
        "pop":  {
                    'year': "Population year",
                    'sex': "Gender (0:male,1:female,2:both,3:unspecified)",
                    'agegroup': "Population age group (5-year) by gender (1-18)",
                    'municid': "Municipality number or any geographical unit",
                    'pop': "Population or population weight or similar weight"
                },
        "case": {
                    'year': "Diagnose year",
                    'sex': "Gender (0:male,1:female,2:both,3:unspecified)",
                    'agegroup': "5-year age group where the person is at diagnose (1-18)",
                    'municid': "Municipality number or any geographical unit",
                    'cases': "Diagnose, death or other cases in aggregated groups" 
                }
    }

    def printHeaderInfo(self,type):
        hdrInfo = self.data_hdr_info[type]
        for columnName,columnInfo in hdrInfo.items():
            print(f"{columnName} : {columnInfo}\n")

    def __init__(self,unitratio = 100000):
        self.unitratio = unitratio # res: 1/100000 persons

# data loading class for population weights and cases        
class DataLoad:
    data=[]
    def __init__(self,dataname = None, filename = False, fs=","):
        self.predefs = Predefs()
        self.header = self.fileHasHdr(filename) ## Should require header in csv, because then data can be real pandas dataframe
        self.fieldsep = fs
        
        if dataname:
            self.label = dataname # "case"/"pop" 
        
        if not filename:
            self.fatalError(f"loading data '{self.label}'",f"No filename '{filename}' exist, please check your PATH!")
        
        self.filename = filename
    
    def execute(self):
        if self.filename:
            if self.header:
                try:
                    print(f"\n* Loading data from {self.filename}")
                    self.data = pd.read_csv(self.filename, header=0, sep=self.fieldsep)
                except Exception as error:
                    print(error)

                if len(self.data)>0:
                    chk=self.csvHeaderCheck()
                    self.fixAgeGroups() if chk else self.fatalError(f"Checking header of '{self.filename}'","\tFailed!\n")

                else:
                    self.fatalError(f"Loading '{self.label}' Data","\tNo data loaded!\n")
            else:
                self.predefs.printHeaderInfo(self.label)
                self.fatalError(f"Loading '{self.label}' Data","\tCSV file doesn't have required header.\n")
                
                #print("\tCSV file doesn't have required header.\n")  # order of the columns are not exact,but names of the columns yes. 
                #                                                       # (cntryid is not required in this version)!
                #print("Quitting because of errors...")
                #sys.sys.exit() # quitting because of errors
                #self.data = pd.read_csv(filename,header=self.header)
            #self.header = test_hdr() # does input really have the header?
            #self.setColumns() 
        else:
            #self.data = []
            self.fatalError(f"Loading '{self.label}' Data","\tNo data loaded!\n",True)

    # Fatal error message for dataload class
    def fatalError(errorLabel, msg, kill = False):
        print(f"Error in {errorLabel}: \n  Error message: {msg}\n") 
        print("    Please, fix before continue!")
        print("Exiting...")
        if kill:
            sys.exit()
    

    # Check agegroups are correct [1-18] instead of [0-17]
    def fixAgeGroups(self):
        if min(self.data.agegroup) == 0 and max(self.data.agegroup == 17):
            self.data.agegroup += 1
        elif min(self.data.agegroup) == 0 and max(self.data.agegroup == 18):
            print("Error: Data have 19 agegroups.")
            return None

#    def setColumns(self):
#        if self.label == "case" and not self.header:
#            self.data.columns = ['cntryid','year','sex','agegroup','municid','cases']
#        elif self.label == "pop" and not self.header:
#            self.data.columns = ['cntryid','year','sex','agegroup','municid','pop']
    
    # return data from object using sex
    def selPopByGender(self,gender):
        return self.data[(self.data.sex == gender)] if gender < 2 else self.data

    # Test: is header having numbers as column names = "it means the same that pd.dataframe generated column names by number"
    def fileHasHdr(self,filename = False):
        # read first not empty line of the file
        if filename:
            with open(filename) as f:
                row = ""
                while len(row) == 0:
                    first_line = f.readline()
                    cols = first_line.split(",")
                    if any(map(lambda x: x.isnumeric(), cols)):
                        return None
                    row = first_line
            return True 
        else:
            return False

    # check that headers are correct, do files have correct columns?
    def csvHeaderCheck(self):
        #predefs = Predefs()
        if self.header and self.label :
            print(f"\nChecking columns for '{self.label}':")
            for col in self.predefs.data_hdr_info[self.label]:
                infostr = f"  {col}:   \t"
                if col in self.data.columns:  #self.predefs.data_hdr_info[self.label]:
                    print(f"{infostr}OK")
                else:
                    print(f"{infostr}False..")
                    print(f"Header error:\n  Required column:\n\n  '{col}' : [{self.predefs.data_hdr_info[self.label][col]}]\n\n  doesn't exist or is in wrong format in {self.label}-data.\n\n")
                    return False
            return True
        else:
            print("Header error:\n Header and/or data name ('pop' or 'case') are not defined.")
            return None


class Runsettings(Predefs):
    #definitions
    age_std_selected = ""
    #calculation specific definitions
     # default = All. You can limit using start and end key of "agegroupdef"
    periods = [] #[[1998,2002],[2001,2005],]
    #gender = 2 # 0 Male, 1 Female
    

    def __init__(self, sex, popfilename, casefilename, popstd='world', agegroups="1-18",unitratio=100000, outputfn = "stdout"):  #agegroups 1-3,5,7-9...
        super().__init__(unitratio)
        """
         preparations
        """
        #self.age_std_selected = super().age_stds[popstd]
        self.agegroups = self.gen_ag_list(agegroups) #gen_ag_list()
        self.gender = sex # 0,1,2=both

        # gen dataframe having indexes for pop stantard
        
        self.age_std_selected = ['agegroup_index',popstd]
        #print(aglist)
        
        self.popfile = popfilename
        self.casefile = casefilename
        self.output = outputfn # default is printing to screen, if filename is not defined. If file exist, this should ask to overwrite
   
    def gen_ag_list(self,agdef):
        """
        parses agegroup seleciton argument
        """
        agdefs = agdef.split(",")
        narr = [] # new list of agegroups
        for part in agdefs:
            if part.isnumeric():
                narr.append()
            elif "-" in part:
                a,b = part.split("-")
                aglist = list(range(int(a),int(b)+1))
                narr.append(aglist)
        return narr
    
    def generatePeriodsAuto(self,population_data,periodlen,yearstep):
        ''' 
        periods are calculated based on so, that last periods are full periods. That's why last period is calculated 1st. Result is reversed in the end.
        '''
        miny = min(population_data.year)
        maxy = max(population_data.year)
        periods = []
#        for yend in range(miny+1,maxy,yearstep):
        print("\nPeriods:")
        for yend in range(maxy,miny+1,-yearstep):
            prow=[]
            start_year = yend-periodlen+1
            end_year = yend
            if start_year < miny and start_year + yearstep > miny:
                prow.append(miny)
                prow.append(end_year)
                periods.append(prow)
                print(prow)
            elif start_year >= miny:
                prow.append(start_year)
                prow.append(end_year)
                periods.append(prow)
                print(prow)
            else:
                #print(start_year,end_year)
                break
        periods.reverse()
        self.periods = periods
        print("\n")
    
    #def generatePeriodsAuto(self,population_data)

# calculation function. Every parameter should be readable from public Objects: datas, settings
def calcASR(popdtObj,casedtObj,settingsobj): #popdt,casedt):
    # datas selected by gender (data obj have usually bot sexes)
    popdt = popdtObj.selPopByGender(settingsobj.gender)
    casedt = casedtObj.selPopByGender(settingsobj.gender)

    # for simplicity
    gender = settingsobj.gender
    periods = settingsobj.periods # done 

    def run_calc():

        resultsp = {}
        resultsc = {}
        tmpres = {}

        # municipality list: All
        r_final = popdt[['municid']].groupby(['municid']).count().reset_index()
        r_final['sex'] = gender
        #r_final.set_index('municid')

        i = 0
        print("Calculating...")
        for yper in periods:
            print(f"Start: {str(yper[0])} - End: {str(yper[1])}" )
            keynm = "k_" +str(i) #results[yper[0]] = []
            pop_by_period = popdt[(popdt.year >= yper[0]) & (popdt.year <= yper[1])]
            case_by_period = casedt[(casedt.year >= yper[0]) & (casedt.year <= yper[1])]
            resultsp[keynm] = pop_by_period[['municid','agegroup','pop']].groupby(['municid','agegroup']).sum('pop')
            #casesum[yper[0]] 
            resultsc[keynm] = case_by_period[['municid','agegroup','cases']].groupby(['municid','agegroup']).sum('cases')
            
            
            # Merge pop and cases correspondig rows by municid and agegroup
            merged_res = resultsp[keynm].merge(resultsc[keynm], left_on=['municid', 'agegroup'], right_index=True).reset_index()
            #print(merged_res)
            
            # Add agestd weight by age group using wstdi (pd.dataframe)
            r = merged_res.merge(settingsobj.age_stds[settingsobj.age_std_selected], left_on=['agegroup'], right_on = ['agegroup_index'])
            
            # calc age stantard rate
            #numpy: rate = sum(np_r[:,1] * np_r[:,2] / np_r[:,0])*100000
            # pandas: 
            r['rateweights'] = r['cases'] * r[settingsobj.age_std_selected[1]] / r['pop'] * settingsobj.unitratio # result: 1/100000 persons
            
            # For debug
            # print(r)
            r_grp = r[['municid','rateweights']].groupby('municid').sum('rateweights').reset_index()
            
            #tmpres[keynm] = r_grp
            # result should look like: municid, period1,...,periodN
            fieldname = f"{str(yper[0])}-{str(yper[1])}"
            #r_grp.rename({'rateweights':fieldname}, axis='columns')
            r_grp = pd.DataFrame({ fieldname: list(r_grp['rateweights'])},index=list(r_grp['municid']))
            tmpres[keynm] = r_grp
            r_final = r_final.set_index('municid',drop=False).join(r_grp,lsuffix='_2')
            #r_final.set_index('municid')
            i += 1

        # reset index and replace Nans with zero (no value here means zero value, it has meaning, because 
        # we know that it is not measeure problem but real situation, where no cases exist
        r_final = r_final.rename({'municid': 'municid_'}, axis='columns')
        r_final = r_final.reset_index().fillna(0)

        # drop extra column 'municid_' and setting the main column 'municid' as index
        # and return
        print("The calculation went fine...")
        return r_final.drop(columns='municid_').set_index('municid')
            
    def save_resultsTocsv(pddfresult, fn):
        # fn = filename to save rates using pandas
        print("Saving the result..")
        pddfresult.to_csv(path_or_buf=fn, na_rep='0.0', float_format="%.4f")
        #r_final.to_csv(path_or_buf='result_test.csv')

    def printData2Screen(data): #,fseparator=","):
        print(data.to_string)
        pd.display(data.to_string)


    result = run_calc()
    if settingsobj.output == "stdout":
        printData2Screen(result)#,settingsobj.output, casedtObj.fieldsep)
    elif os.path.exists(settingsobj.output):
        print("Output file exist, do you like to overwrite, (Y)es or (N)o? ")
        ans = input()
        if ans.upper() == "Y":
            save_resultsTocsv(result, settingsobj.output)
        else:
            printData2Screen(result)#,settingsobj.output, casedtObj.fieldsep)
    elif not os.path.exists(settingsobj.output):
        save_resultsTocsv(result, settingsobj.output)
    print("\nQuiting..")
    return result


# Main function for single run

def start_main(gender, popfilename, casefilename, popstd, agegroups, periods=None, periodlength=5, periodstep=2):
    popdtObj = DataLoad("pop", popfilename)
    casedtObj = DataLoad("case", casefilename)
    # loop this function when making several similar calculations of list of 
    # settings class init: sex,popfilename,casefilename,popstd = 'world',agegroups 1-18
    settingsobj = Runsettings(gender, popfilename, casefilename, popstd, agegroups ) 
    if periods == None:
        settingsobj.generatePeriodsAuto( popdtObj.data, periodlength, periodstep )
    else:
        settingsobj.periods = periods
    result = calcASR(popdtObj,casedtObj,settingsobj)
    return result

def runFromCommanLine(*params):
    for item in list( map( lambda x: f"{x}|" , params)):
        print(item)
    print("Error: Run from commandline is not implemented yet!")


def help():
    print("""
    
    Help:
    
    """)
    print(Version())


if __name__ == '__main__':
    # test if run by commandline
    if len(sys.argv) and (len(sys.argv)<3 or "-h" in sys.argv):
        help()
    elif len(sys.argv) and len(sys.argv)>=3:
        runFromCommanLine(*sys.argv)
    else:    
        print("""
    No Arguments Try Again. "-h" for help
    """)
