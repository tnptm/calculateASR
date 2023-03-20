import sys
from calcinc_mo import load_cases,load_pop,settings,defineperiodlist
import numpy as np
#import pandas as pd

load_pop()
load_cases()

s = settings
s.agestandard = 'wstd'
# print(sys.argv)
ags = "1-18" if sys.argv and len(sys.argv) == 1 else sys.argv[1]
print(s.agestdlist(s,ags))

