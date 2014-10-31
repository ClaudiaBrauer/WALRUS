### Getting started 

# Remove everything from R's memory.
rm(list=ls())

# Load the WALRUS package.
library(WALRUS)

# Change working directory.
setwd("D:/Dropbox/WALRUS/examples/")


### Parameters

# Option 1: define the parameters and initial conditions manually.
pars = data.frame(cW=500, cV=4, cG=5e6, cQ=1, cS=5, 
                  dG0=1000, cD=1500, aS=0.01, st="loamy_sand")
# The options for st (soil type) are: 
# "sand", "loamy_sand", "sandy_loam", "silt_loam", "loam", "sandy_clay_loam", 
# "silt_clay_loam", "clay_loam", "sandy_clay", "silty_clay", "clay", "cal_H", "cal_C"). 
# The values for "cal_H" and "cal_C" were obtained by fitting on observations in 
# the Hupsel Brook catchment and Cabauw polder.

# Option 2: read a parameter set from file.
pars = read.table("output/pars_NS_basic_example.dat", header=TRUE)


### Initial conditions

# The initial conditions can be set in four ways. 
# Option 1: set the groundwater depth at t=0 
# (in this case at 1000 mm) with the argument dG0=1000.
# This option is also used in the basic example.
pars = data.frame(cW=500, cV=4, cG=5e6, cQ=1, cS=5, 
                  dG0=1000, cD=1500, aS=0.01, st="loamy_sand")

# Option 2: specify the fraction of discharge which originates from groundwater 
# (in this case 80%), with the argument Gfrac=0.8.
pars = data.frame(cW=500, cV=4, cG=5e6, cQ=1, cS=5, 
                  Gfrac=0.8, cD=1500, aS=0.01, st="loamy_sand")

# Option 3: without specifying either dG0 or Gfrac. 
# By default, all discharge will be assumed to originate from groundwater.  
pars = data.frame(cW=500, cV=4, cG=5e6, cQ=1, cS=5, 
                  cD=1500, aS=0.01, st="loamy_sand")

# Option 4: without specifying either dG0 or Gfrac, but by using a warming-up period.
# During this period, the model is run, but the output is not stored and
# used to compute goodness of fit.
# The warming-up period is specified with the forcing time series in hours.
# For example, if you want a warming-up period of one month:
data = read.table("data/PEQ_Hupsel.dat", header=TRUE)       # read data
forc = WALRUS_selectdates("data", 2011120000, 2012020000)   # select specific period
forc$warm = 24*30                                           # define warming-up period 
WALRUS_preprocessing(f=forc, dt=1)                          # run preprocessing function


