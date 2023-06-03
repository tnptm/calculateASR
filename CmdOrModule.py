#!/usr/bin/python3
#
# This script helps to visualize what happened if script is run from command line with N arguments versus imported as module.
# As module function from_cli is not possible. At the same time function "run_as_module" is not able start from commandline. 
# But finally both will execute the main function
#
# 
import sys

def main(*args):
    print("Running main...")
    print("function args:", ",".join(args))
    if len(args)>0 and '-h' in args:
        print("""\nHELP:
Test script which can be running from command line and as module executing the same main func
1) python CmdOrModule.py "Hi from CLI!"
2) import CmdOrModule as com
   com.run_as_module("Hi from Module!")
""")

def run_as_module(*arguments):
    print("run as MODULE")
    main(*arguments)

if __name__=='__main__':
    def from_cli():
        print("Running from command line..")
        print('Argument list:', sys.argv)
        main(*sys.argv)
    from_cli()
