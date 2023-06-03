import numpy as np
import pandas as pd
import sys

def Version():
    return "0.1/30042023 toni.patama@gmail.com"

class Predefs:
    age_stds = {'world':[12,10,9,9,8,8,6,6,6,6,5,4,4,3,2,1,.5,.5]}
    agegroupdef = {
        "0-4": 1,"5-9": 2,"10-14": 3,"15-19": 4,"20-24": 5,"25-29": 6,"30-34": 7,"35-39": 8,"40-44": 9,
        "45-49": 10,"50-54": 11,"55-59": 12,"60-64": 13,"65-69": 14,"70-74": 15,"75-79": 16,"80-84": 17, "85+":18,
    }
    def __init__(self,unitratio = 100000):
        self.unitratio = unitratio # res: 1/100000 persons

        
class DataLoad:
    def __init__(self,dataname = False, filename = False, fs=","):
        self.header = self.fileHasHdr(filename)
        self.fieldsep = fs
        self.label = dataname # "case"/"pop" 
        if filename:
            if self.header:
                self.data = pd.read_csv(filename)
            else:
                self.data = pd.read_csv(filename,header=self.header)
            self.filename = filename
            #self.header = test_hdr() # does input really have the header?
            self.setColumns()
            self.fixAgeGroups()
        else:
            self.data = []

    # Check agegroups are correct
    def fixAgeGroups(self):
        if min(self.data.agegroup) == 0 and max(self.data.agegroup == 17):
            self.data.agegroup += 1
        elif min(self.data.agegroup) == 0 and max(self.data.agegroup == 18):
            print("Error: Data have 19 agegroups.")
            quit()

    def setColumns(self):
        if self.label == "case" and not self.header:
            self.data.columns = ['cntryid','year','sex','agegroup','municid','cases']
        elif self.label == "pop" and not self.header:
            self.data.columns = ['cntryid','year','sex','agegroup','municid','pop']
    
    # return data from object using sex
    def selPopByGender(self,gender):
        return self.data[(data.sex == gender)] if gender < 2 else data

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


#class CaseData(DataLoad):
#    def __init__(self,**kwds): #filename,fs=",",header = False):
#        super().__init__(**kwds)

#class PopulationDt(DataLoad):
#    def __init__(self,**kwds): #filename,fs=",",header = False):
#        super().__init__(**kwds)
#        self.data.columns = ['cntryid','year','sex','agegroup','municid','cases']


#class Cases:
#    def __init__(self,filename,fs=",",header = False):
#        self.casedt = pd.read_csv(filename,header)
#    def selPopByGender(self,gender)
#        return self.casedt[(casedt.sex == gender)] if gender < 2 else casedt
    


class Runsettings(Predefs):
    #definitions
    age_std_selected = ""
    #calculation specific definitions
     # default = All. You can limit using start and end key of "agegroupdef"
    periods = [] #[[1998,2002],[2001,2005],[2004,2008],[2007,2012]]
    gender = 2 # 0 Male, 1 Female
    

    def __init__(self,sex,popfilename,casefilename,popstd = 'world',agegroups = "1-18"): # 1-3,5,7-9...
        super().__init__(unitratio = 100000)
        """
         preparations
        """
        #self.age_std_selected = super().age_stds[popstd]
        self.agegroups = self.gen_ag_list(agegroups) #gen_ag_list()
        self.gender = sex # 0,1,2=both

        # gen dataframe having indexis for pop stantard
        aglist = super().age_stds[popstd]
        s = pd.DataFrame(index=list(range(1,len(aglist)))) #
        self.age_std_selected = s.join(super().age_stds[popstd])
        self.popfile = popfilename
        self.casefile = casefilename

   
    def gen_ag_list(agdef):
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
    
    def generatePeriodsAuto(self,population_data):
        return 0
    #def generatePeriodsAuto(self,population_data)

# calculation function. Every parameter should be readable from public Objects: datas, settings
def calcASR(): #popdt,casedt):
    popdt = popdtObj.data
    casedt = casedtObj.data
    gender = settingsobj.gender
    periods = settingsobj.periods # needed to implement!!!

    def run_calc():

        resultsp = {}
        resultsc = {}
        tmpres = {}

        # municipality list: All
        r_final = popdt[['municid']].groupby(['municid']).count().reset_index()
        r_final['sex'] = gender
        #r_final.set_index('municid')

        i = 0
        for yper in periods:
            print(f"Start: {str(yper[0])} - End: {str(yper[1])}" )
            keynm = "k_" +str(i) #results[yper[0]] = []
            pop_by_period = popdt[(popdt.year >= yper[0]) & (popdt.year <= yper[1])]
            case_by_period = casedt[(casedt.year >= yper[0]) & (casedt.year <= yper[1])]
            resultsp[keynm] = pop_by_period[['municid','agegroup','pop']].groupby(['municid','agegroup']).sum('pop')
            #casesum[yper[0]] 
            resultsc[keynm] = case_by_period[['municid','agegroup','cases']].groupby(['municid','agegroup']).sum('cases')
            
            
            # Merge pop and cases correspondig rows by municid and agegroup
            merged_res = resultsp[keynm].merge(resultsc[keynm], left_on=['municid', 'agegroup'], right_index=True)
            
            # Add agestd weight by age group using wstdi (pd.dataframe)
            r = merged_res.merge(wstdi, left_on=['agegroup'], right_index=True).reset_index()
            
            # calc age stantard rate
            #numpy: rate = sum(np_r[:,1] * np_r[:,2] / np_r[:,0])*100000
            # pandas: 
            r['rateweights'] = r['cases'] * r['wstd'] / r['pop'] * unitratio # result: 1/100000 persons
            r_grp = r[['municid','rateweights']].groupby('municid').sum('rateweights').reset_index()
            #tmpres[keynm] = r_grp
            # result should look like: municid, period1,...,periodN
            fieldname = f"{str(yper[0])}-{str(yper[0])}"
            #r_grp.rename({'rateweights':fieldname}, axis='columns')
            r_grp = pd.DataFrame({ fieldname: list(r_grp['rateweights'])},index=list(r_grp['municid']))
            tmpres[keynm] = r_grp
            r_final = r_final.set_index('municid',drop=False).join(r_grp,lsuffix='_2')
            #r_final.set_index('municid')
            i += 1

        # reset index and replace Nans with zero (no value here means zero value, it has meaning, because 
        # we know that it is not measeure problem but real situation, where no cases exist
        r_final=r_final.rename({'municid': 'municid_'},axis='columns')
        r_final.reset_index().fillna(0)
    
    def save_resultsTocsv(self,fn=None):
        r_final.to_csv(path_or_buf='result_test.csv')

    run_calc()


# Main function for single run
def start_main(gender,popfile,casefile):
    popdtObj = DataLoad("pop", popfile)
    # loop this function when making several similar calculations of list of 
    settingsobj = Runsettings(gender,popfile,casefile,header)
    calcASR(popdt)

def runFromCommanLine():
    print("Not implemented yet")

# municipality list: All
#r_final = popdt[['municid','sex']].groupby('municid').agg('sex').reset_index()

# here is supposed that data have all 18 agegroups defined
#agsascols = popdt[['year','municid','agegroup','pop']].groupby(['year','municid','agegroup']).sum('pop').unstack(level=-1)
#nd = agsascols.add_prefix('a_')
#nd = nd.a_pop.reset_index()
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
        start_main(*sys.argv)
    else:    
        Print("""
    No Arguments Try Again. "-h" for help
    """)
    # else run as python module directly