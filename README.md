# Calculate ASR
Python script for calculating Age Standard Rates of Cancer Incidence and Mortality

Reimplement Calc_inc (Calclulate incidences) using more popular prorgramming language (Python) than Perl, which made calculation faster however.

Script is calculatin age standardized rates of periods of years, like 2000-2005 over even tens of years. The periods can overlap with each others 
i.e 2000-2010,2005-2015 etc.

It will be python kind of library which can be used part of other scripts like batch scripts. It needs a 
control script, where library classes and functions are called and settings defined for
every run. This batch script works as an documentations of what was made for calculation.

Library is in calcAsr.py and it has a sample of the batch script runAsr.py. The library will be possible to run later stand alone.

INSTALLING

To run these files, you would need python 3 version installed (python.org) on your computer. And you have to isntall also additional
libraries for it numpy and pandas.

They can be installed from command line using pip. It is recommended to use virtual environment for this purpose as shown below (Linux):

	cd installdir
	python -m venv venv
	. venv/bin/activate
	pip install pandas

Then it is possible to run the script:

	python runAsr.py case_file.csv

Some optimizations to code can be done still. However this kind of solution helps to minimize running the same code without purpose. For example
usually population data is always the same. Only cancer type is changing. So population is loaded to memory only once. Then repeating calculations using that for
all the cancer types will be more fluent.
