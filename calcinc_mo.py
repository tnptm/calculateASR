#!/usr/bin/python3
#import pandas as pd
import numpy as np

def load_pop():
    print("Loading population...")
    print("OK")
    return

def load_cases():
    print("Loading cases...")
    print("OK")
    return

class settings:
    agestandard = 'wstd'
    yperiods = []
    numofperiods = []
    periodsastext = ""
    agegroupdef = {
            "0-4": 1,"5-9": 2,"10-14": 3,"15-19": 4,"20-24": 5,"25-29": 6,"30-34": 7,"35-39": 8,"40-44": 9,
            "45-49": 10,"50-54": 11,"55-59": 12,"60-64": 13,"65-69": 14,"70-74": 15,"75-79": 16,"80-84": 17, "85+":18,
            }
    
    #agegroups = 1-18 # default 1-18: 0-4,5-9,...,85+
    def __init__(self,startyear = 0,endyear = 0,perdiff = 0, perlen=0, psastxt=""):
        if perdiff > 0 and startyear > 0 and endyear > 0:
            self.yperiods = defineperiodlist(startyear, endyear, perdiff, perlen)
        self.periodsastext = psastxt
    
    def agestdlist(self,agegroups):
        agestddef = {"wstd":[12,10,9,9,8,8,6,6,6,6,5,4,4,3,2,1,.5,.5]}
        agmin,agmax = agegroups.split("-")
        agmin = int(agmin) - 1
        agmax = int(agmax)
        return agestddef[self.agestandard][agmin:agmax]

    def stringifyperiods(self):
        txtplist=[]
        for r in self.yperiods:
            r=map(str,r)
            txtplist.append("-".join(r))
        return txtplist

    def converttxtperiodstoobj(self,psastxt):
        periods = psastxt.split(":")
        #pmat = []
        #for p in periods:
        #    pmat.append(map(int, p.split("-")))
        pmat = [list(map(int, p.split("-"))) for p in periods]
        self.yperiods = pmat

def defineperiodlist(starty,endy,diffyrs,plength):
    periodlist = []
    if plength:
        for sy in range(starty,endy - diffyrs,diffyrs):
            sepair = [sy, sy+plength]
            if sepair[1]>endy:
                sepair[1] = endy
            periodlist.append(sepair)
    else:
        periodlist = [[starty,endy]]
    return periodlist


class populationdata:
    rawdata = []
    def __init__(self,popdata):
        self.rawdata=popdata
    def minmaxyears(self):
        return
    def municipalitylist(self):
        return


class calculator:
    def __init__(self,popobj,settingsobj,casesobj,gender):
        #prepare calc

        #init calc

        #result obj?

    def np_calcASR(n_pop, n_cases, n_wstd):
        # Numpy arrays in one line (many years already aggregated to one row)
        return sum(n_wstd * n_cases/ n_pop)*100000
#class results:
    #collect results as strcture (json) object: [cancer type: {result}]
    #save data as json or text? (json is possible to upload directly to other compatible system)
    #json structure could be
    #    [cancertype:{
    #        gender, municipalitydata:{cntry: [municipalityid, rowid]}, periods:[periodname,periodata:{

    #        }]
    #    }]