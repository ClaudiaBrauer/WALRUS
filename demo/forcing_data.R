### Getting started 

# Remove everything from R's memory.
rm(list=ls())

# Load the WALRUS package.
library(WALRUS)

# Change working directory to the folder where data-, figures- and output-subfolders 
#are located.
setwd("D:/Dropbox/WALRUS/examples/")


### Data

# Read daily or hourly precipitation, potential evapotranspiration and discharge data.
data = read.table("data/PEQ_Hupsel.dat", header=TRUE)

# Specify which period of the total data set you want to use as forcing data
# use the same date format as in data file (for example YYYYmmddHH).
forc = WALRUS_selectdates("data", 2011120000, 2012000000)

# Preprocessing forcing and output data file. The argument dt is time step size used 
# in output data file (in hours).
WALRUS_preprocessing(f=forc, dt=1)





